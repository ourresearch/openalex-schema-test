import argparse
import pathlib
import re
import subprocess
import time
from textwrap import indent

import boto3


def run_sql(db_url, filename, psql_echo=False):
    echo_arg = '-v ECHO=queries' if psql_echo else ''
    return subprocess.check_output(
        f'psql -v ON_ERROR_STOP=ON {echo_arg} {db_url} < {filename}',
        shell=True,
        universal_newlines=True,
        stderr=subprocess.STDOUT
    )


def format_size(num_bytes):
    prefix = 0

    while num_bytes > 1000:
        num_bytes = num_bytes / 1000
        prefix += 1

    return f'{round(num_bytes, 1)}{"bkMGTPEZY"[prefix]}'


def download_tables_from_s3(bucket, prefix, tables, rows_to_download, use_local_files):
    if not prefix.endswith('/'):
        prefix = f'{prefix}/'

    print(f'download files from s3://{bucket}/{prefix}')

    s3_keys = boto3.resource('s3').Bucket(bucket).objects.filter(Prefix=prefix)

    for table in tables:
        print(f'  download {table}')

        local_files = pathlib.Path('input/').rglob(f'{table}.txt*')

        if use_local_files:
            for local_file in local_files:
                print(f'    keeping local file {local_file}')
            continue

        for local_file in local_files:
            print(f'    delete {local_file}')
            # local_file.unlink()

        for key in s3_keys:
            if f'{table}.txt' not in key.key:
                continue

            file_name = key.key.replace(prefix, 'input/')
            file_path = pathlib.Path(file_name)

            print(f'    download s3://{bucket}/{key.key} to {file_name}')
            file_path.parent.mkdir(parents=True, exist_ok=True)

            with open(file_name, 'w') as f:
                rows_done = -1
                bytes_done = 0
                for row in key.get()['Body'].iter_lines(keepends=True):
                    bytes_done += len(row)

                    f.write(row.decode())
                    rows_done += 1

                    if rows_done % 1000 == 0:
                        print(f'      downloaded {rows_done} rows, {format_size(bytes_done)}', end='\r')

                    if rows_to_download and rows_done >= rows_to_download:
                        break

                print(f'      downloaded {rows_done} rows')


def list_all_tables():
    tables = {}

    for table_sql in pathlib.Path('sql/tables/').iterdir():
        tables[table_sql.name.replace('.sql', '')] = str(table_sql)

    return tables


def test_load_tables(db_url, tables, print_psql, psql_echo):
    passed_tables = []
    failed_tables = {}

    print('initialize database')
    init_output = run_sql(db_url, 'sql/init.sql', psql_echo)
    if print_psql:
        print(indent(init_output, '    '))

    print('test tables')

    for table, sql_filename in tables.items():
        print(f'  test {table}')

        if pathlib.Path(sql_filename).is_file():
            try:
                test_output = run_sql(db_url, sql_filename, psql_echo)

                if print_psql:
                    print(indent(test_output, '    '))

                print('    PASSED')
                passed_tables.append(table)
            except subprocess.CalledProcessError as e:
                print(f'    FAILED, exception running {sql_filename}')
                print(indent(e.output, '    '))
                failed_tables[table] = e.output
        else:
            error = f'table definition {sql_filename} not found'
            print(f'    FAILED, {error}')
            failed_tables[table] = error

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
    db_addon = parsed_args.db_addon or create_db_addon(parsed_args.app, parsed_args.db_plan)

    try:
        if not db_addon:
            print('no database addon to use, so not running any tests')
            return
        else:
            print(f'using heroku postgres addon {db_addon}')

        all_tables = list_all_tables()

        if parsed_args.tables:
            run_tables = {name: all_tables[name] for name in parsed_args.tables if name in all_tables}
        else:
            run_tables = all_tables

        download_tables_from_s3(
            parsed_args.bucket,
            parsed_args.prefix,
            run_tables.keys(),
            parsed_args.rows,
            parsed_args.use_local_files
        )

        db_url = get_test_db_url(parsed_args.app, db_addon)

        if not db_url:
            print(f'not able to find URL for {db_addon}, so not running any tests')
            return

        test_load_tables(db_url, run_tables, parsed_args.print_psql, parsed_args.psql_echo)
    finally:
        if not parsed_args.db_addon:
            print('\n')
            print(f'The heroku postgres addon {db_addon} was created on {parsed_args.app} to run these tests.')
            print(f'Destroy it by running the command `heroku addons:destroy {db_addon} --app {parsed_args.app}`')
            print(f'or reuse it by running this script with the option `--db-addon=={db_addon}')
            input()


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
    test_db_specs.add_argument('--db-plan', '-p', default='standard-7', help='heroku postgres plan to use for test db')
    test_db_specs.add_argument('--db-addon', '-d', help='name of heroku postgres addon containing test database')

    run(ap.parse_args())
