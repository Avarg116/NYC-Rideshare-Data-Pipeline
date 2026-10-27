create role loader_role login password :'loader_pw';
create role dbt_role login password :'dbt_pw';

grant create on database warehouse to loader_role;
grant create on database warehouse to dbt_role;

set role loader_role;

create schema if not exists raw;
grant usage on schema raw to dbt_role;
alter default privileges in schema raw grant select on tables to dbt_role;

set role dbt_role;

create schema if not exists dbt_schema;
