import argparse
import concurrent.futures
import pathlib
import re
import subprocess
import sys
import time
from functools import partial
from io import StringIO
from textwrap import indent

import boto3


def run_sql(db_url, filename, psql_echo=False, drop_after_test=False):
    echo_arg = '-v ECHO=queries' if psql_echo else ''
    drop_table_arg = f'-v DROP_TABLE_AFTER_TEST={1 if drop_after_test else 0}'
    return subprocess.check_output(
        f'psql -v ON_ERROR_STOP=ON {echo_arg} {drop_table_arg} {db_url} < {filename}',
        shell=True,
        universal_newlines=True,
        stderr=subprocess.STDOUT
    )


def list_local_files(table):
    return list(pathlib.Path('input/').rglob(f'{table}.txt*'))


def delete_local_files(table):
    for local_file in list_local_files(table):
        print(f'    delete {local_file}')
        local_file.unlink()


def download_table_from_s3(bucket, prefix, table, rows_to_download, use_local_files):
    if not prefix.endswith('/'):
        prefix = f'{prefix}/'

    s3_keys = boto3.resource('s3').Bucket(bucket).objects.filter(Prefix=prefix)

    print(f'  download {table} from s3://{bucket}/{prefix}')

    if use_local_files and (local_files := list_local_files(table)):
        for local_file in local_files:
            print(f'    keeping local file {local_file}')
        return

    delete_local_files(table)

    rows_done = -1
    bytes_done = 0

    for key in s3_keys:
        if f'/{table}.txt' not in key.key:
            continue

        file_name = key.key.replace(prefix, 'input/')
        file_path = pathlib.Path(file_name)

        file_path.parent.mkdir(parents=True, exist_ok=True)

        if rows_to_download:
            print(f'    download s3://{bucket}/{key.key} to {file_name}')

            with open(file_name, 'w') as f:
                for row in key.get()['Body'].iter_lines(keepends=True):
                    bytes_done += len(row)

                    f.write(row.decode())
                    rows_done += 1

                    if rows_to_download and rows_done >= rows_to_download:
                        break

                print(f'      downloaded {rows_done} rows')
        else:
            cp_cmd = f'aws s3 cp s3://{bucket}/{key.key} {file_name} --no-progress'
            with subprocess.Popen(cp_cmd, stdout=subprocess.PIPE, bufsize=1, universal_newlines=True, shell=True) as p:
                for line in p.stdout:
                    print(f'      {line}')

            if p.returncode != 0:
                raise subprocess.CalledProcessError(p.returncode, p.args)

        if rows_to_download and rows_done >= rows_to_download:
            break


def list_all_tables():
    tables = {}

    for table_sql in pathlib.Path('sql/tables/').iterdir():
        tables[table_sql.name.replace('.sql', '')] = str(table_sql)

    return tables


def test_table(table, test_options):
    string_stdout = StringIO()
    sys.stdout = string_stdout

    table_name = table['name']
    sql_filename = table['filename']

    print_psql = test_options['print_psql']
    psql_echo = test_options['psql_echo']
    drop_after_test = test_options['drop_after_test']
    use_local_files = test_options['use_local_files']
    delete_files = test_options['delete_files']
    db_url = test_options['db_url']
    bucket = test_options['bucket']
    prefix = test_options['prefix']
    rows_to_download = test_options['rows_to_download']

    error = None
    print(f'test {table_name}')

    try:
        download_table_from_s3(bucket, prefix, table_name, rows_to_download, use_local_files)
    except Exception as e:
        error = f'FAILED, exception getting files from S3: {e}'
        print(indent(error, '    '))

    if not error:
        if pathlib.Path(sql_filename).is_file():
            try:
                print(f'  run {sql_filename}')
                test_output = run_sql(db_url, sql_filename, psql_echo, drop_after_test)

                if print_psql:
                    print(indent(test_output, '    '))

                print('  PASSED')
            except subprocess.CalledProcessError as e:
                print(f'  FAILED, exception running {sql_filename}')
                error = e.output
                print(indent(error, '    '))
        else:
            error = f'table definition {sql_filename} not found'
            print(f'  FAILED, {error}')

    if delete_files == 'always' or (delete_files == 'if_passed' and error is None):
        delete_local_files(table_name)

    return {
        'success': error is None,
        'error': error,
        'name': table_name,
        'output': string_stdout.getvalue()
    }


def test_load_tables(db_url, tables, parsed_args):
    passed_tables = []
    failed_tables = {}

    print('initialize database')
    init_output = run_sql(db_url, 'sql/init.sql', parsed_args.psql_echo)
    if parsed_args.print_psql:
        print(indent(init_output, '    '))

    print('test tables')

    test_options = {
        'print_psql': parsed_args.print_psql,
        'psql_echo': parsed_args.psql_echo,
        'drop_after_test': parsed_args.drop_tables == 'if_passed',
        'use_local_files': parsed_args.use_local_files,
        'db_url': db_url,
        'bucket': parsed_args.bucket,
        'prefix': parsed_args.prefix,
        'rows_to_download': parsed_args.rows,
        'delete_files': parsed_args.delete_files,
    }

    table_dicts = [{'name': name, 'filename': filename} for name, filename in tables.items()]

    with concurrent.futures.ProcessPoolExecutor(max_workers=parsed_args.threads) as pool:
        table_tests = pool.map(
            partial(test_table, test_options=test_options),
            table_dicts,
            chunksize=1
        )

        for table_test in table_tests:
            print(indent(table_test['output'].strip(), '  '))
            if table_test['success']:
                passed_tables.append(table_test['name'])
            else:
                failed_tables[table_test['name']] = table_test['error']

    print('passed tables')
    print(indent('\n'.join(passed_tables) if passed_tables else '(None)', '  '))

    print('failed tables')

    for table, output in failed_tables.items():
        print(f'  {table}')
        print(indent(output, '    '))

    if not failed_tables:
        print('  (None)')


def create_db_addon(heroku_app, db_plan):
    addon_create_cmd = f'heroku addons:create heroku-postgresql:{db_plan} --app {heroku_app}'

    while (answer := input(f'Create a new DB with command `{addon_create_cmd}`? (y/n) ').lower()) not in ['y', 'n']:
        pass

    if not answer.lower() == 'y':
        return None

    addon_create_output = subprocess.check_output(addon_create_cmd, shell=True, text=True, stderr=subprocess.STDOUT)

    addon_name = None

    for line in addon_create_output.split('\n'):
        if matches := re.findall(r'^([a-z0-9-]+) is being created in the background', line):
            addon_name = matches[0]
        if re.search(r'\$[0-9.]+/month', line) or 'should be available' in line:
            print(line)

    if not addon_name:
        print('not able to find addon name in create command output')
        print(indent(addon_create_output, '  '))

    return addon_name


def get_test_db_url(heroku_app, addon):
    wait_cmd = f'heroku pg:wait {addon} --app {heroku_app}'
    print(f'waiting for database: {wait_cmd}')
    subprocess.check_output(wait_cmd, shell=True, text=True, stderr=subprocess.STDOUT)
    print(f'  database ready')

    print(f'get attachment name for {addon} on {heroku_app}')

    pg_info_cmd = f'heroku pg:info --app {heroku_app}'
    pg_info_output = subprocess.check_output(pg_info_cmd, shell=True, text=True, stderr=subprocess.STDOUT)
    addon_attachment = None
    pg_info_current_attachment = None

    for line in pg_info_output.split('\n'):
        if line.startswith('=== '):
            pg_info_current_attachment = line.replace('=== ', '')

        if line.startswith('Add-on:') and line.endswith(addon):
            addon_attachment = pg_info_current_attachment
            break

    if not addon_attachment:
        print(f'not able to find attachment name for {addon} in pg:info output')
        print(indent(pg_info_output, '  '))
        return None

    print(f'  attachment name is {addon_attachment}')

    db_url = None

    sleep = 1
    cumulative_sleep = 0
    config_get_cmd = f'heroku config:get {addon_attachment} --app {heroku_app}'

    while not db_url and cumulative_sleep <= 60:
        db_url = subprocess.check_output(config_get_cmd, shell=True, text=True, stderr=subprocess.STDOUT).strip()
        time.sleep(sleep)
        cumulative_sleep += sleep
        sleep *= 1.5

    return db_url


def run(parsed_args):
    new_db = False

    if parsed_args.db_addon:
        db_addon = parsed_args.db_addon
    elif parsed_args.db_plan:
        db_addon = create_db_addon(parsed_args.app, parsed_args.db_plan)
        new_db = True
    else:
        default_db_addon = 'postgresql-amorphous-83485'
        print(f'no --db-addon or --db-plan specified, trying default database {default_db_addon} on {parsed_args.app}')
        if get_test_db_url(parsed_args.app, default_db_addon):
            print(f'  success')
            db_addon = default_db_addon
        else:
            print(f'  failed, creating a new standard-7 database on {parsed_args.app}')
            db_addon = create_db_addon(parsed_args.app, 'standard-7')
            new_db = True

    try:
        if not db_addon:
            print('no database addon to use, so not running any tests')
            return
        else:
            print(f'using heroku postgres addon {db_addon} on {parsed_args.app}')

        all_tables = list_all_tables()

        if parsed_args.tables:
            run_tables = {name: all_tables[name] for name in parsed_args.tables if name in all_tables}
        else:
            run_tables = all_tables

        db_url = get_test_db_url(parsed_args.app, db_addon)

        if not db_url:
            print(f'not able to find URL for {db_addon}, so not running any tests')
            return

        test_load_tables(db_url, run_tables, parsed_args)
    finally:
        if new_db and db_addon:
            print('\n')
            print(f'The heroku postgres addon {db_addon} was created on {parsed_args.app} to run these tests.')
            print(f'Destroy it by running the command `heroku addons:destroy {db_addon} --app {parsed_args.app}`')
            print(f'or reuse it by running this script with the option `--db-addon=={db_addon}')
            input()


def drop_tables_choices():
    return ['never', 'if_passed']


def delete_files_choices():
    return ['never', 'if_passed', 'always']


if __name__ == '__main__':
    ap = argparse.ArgumentParser()

    input_files = ap.add_argument_group('input files')
    input_files.add_argument('--bucket', default='openalex', help='S3 bucket contaning the table files')
    input_files.add_argument('--prefix', default='data_dump_v1/2021-10-11/', help='common prefix for the table files')
    input_files.add_argument('--use-local-files', default=False, action='store_true', help='use local table files if already downloaded')
    input_files.add_argument('--tables', '-t', action='extend', nargs='*', help='table names to test', choices=list_all_tables().keys())
    input_files.add_argument('--rows', '-r', type=int, default=None, help='number of rows to load from each table')

    sql_logging = ap.add_argument_group('sql logging')
    sql_logging.add_argument('--print-psql', default=False, action='store_true', help='print psql output')
    sql_logging.add_argument('--psql-echo', default=False, action='store_true', help='echo queries in psql output')

    test_database = ap.add_argument_group('test database')
    test_database.add_argument('--app', '-a', default='oadoi-staging', help='heroku app to attach the test database to')
    test_db_specs = test_database.add_mutually_exclusive_group()
    test_db_specs.add_argument('--db-plan', '-p', help='heroku postgres plan to use for test db, e.g. standard-7')
    test_db_specs.add_argument('--db-addon', '-d', help='name of heroku postgres addon containing test database, e.g. postgresql-amorphous-83485')

    cleanup = ap.add_argument_group('cleanup')
    cleanup.add_argument('--drop-tables', default='if_passed', choices=drop_tables_choices(), help='condition in which to drop test db tables')
    cleanup.add_argument('--delete-files', default='if_passed', choices=delete_files_choices(), help='condition in which to delete local data')

    ap.add_argument('--threads', type=int, default=1, help='number of tables to test in parallel')

    run(ap.parse_args())
