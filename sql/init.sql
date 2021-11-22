create extension if not exists postgis;
create extension if not exists pg_trgm;

drop schema if exists mag cascade;
create schema mag;
