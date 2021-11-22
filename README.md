# OpenAlex schema test

This script downloads OpenAlex data files from S3 and copy them to a postgres database.

It copies the files to the local machine and copies them to the database using scripts in ./sql/tables.
To be safe you'll want about 1TB available on the local machine and 2TB on the database if testing all tables.

## Setup

This script requires python >= 3.8 and boto3 >= 1.18.

### Heroku

Test databases are created and addressed as heroku addons using the heroku CLI. Install and log into it: https://devcenter.heroku.com/articles/heroku-cli

### AWS

Files are downloaded from S3 using the boto3 library. Set the AWS_PROFILE or AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables so it can access them.

### Test database

The database is addressed using its heroku addon name. This is the addon name, not the attachment name. If pg:info shows

```text
=== HEROKU_POSTGRESQL_NAVY_URL
Plan:                  Standard 7
Status:                Available
Data Size:             15.5 MB
Add-on:                postgresql-amorphous-83485

```

You want `postgresql-amorphous-83485`. You can create the database ahead of time and specify it as `--db-addon postgresql-amorphous-83485` 
or have a database created for you using `--db-plan standard-7`. The list of available plans is here: https://elements.heroku.com/addons/heroku-postgresql#pricing

Addons are provisioned on the `oadoi-staging` app by default. You can use a different one with the `--app` option.

## Running tests

To test all tables using a Standard-7 database, run:

`python run_test.py --db-plan standard-7`

Test a subset of tables using `--table / -t`:

`python run_test.py --db-addon postgresql-amorphous-83485 -t Papers -t Authors`

Test the first N rows of each file with `--rows N/ -r N`:

`python run_test.py --db-addon postgresql-amorphous-83485 --rows 100000`

`--rows` and `--table` can be combined:

```text

$ AWS_PROFILE=ourresearch python run_test.py -t Papers -t Authors --db-addon postgresql-amorphous-83485 -r 10000
using heroku postgres addon postgresql-amorphous-83485 on oadoi-staging
download files from s3://openalex/data_dump_v1/2021-10-11/
  download Papers
    delete input/mag/Papers.txt
    download s3://openalex/data_dump_v1/2021-10-11/mag/Papers.txt to input/mag/Papers.txt
      downloaded 10000 rows, 3.4M
  download Authors
    delete input/mag/Authors.txt
    download s3://openalex/data_dump_v1/2021-10-11/mag/Authors.txt to input/mag/Authors.txt
      downloaded 10000 rows, 775.4k
waiting for database: heroku pg:wait postgresql-amorphous-83485 --app oadoi-staging
  database ready
get attachment name for postgresql-amorphous-83485 on oadoi-staging
  attachment name is HEROKU_POSTGRESQL_NAVY_URL
initialize database
test tables
test Papers
    PASSED
test Authors
    PASSED
passed tables
  Papers
  Authors
failed tables
  (None)

```

