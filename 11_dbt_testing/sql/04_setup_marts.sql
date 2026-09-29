-- Use SYSADMIN because this role manages databases, schemas, tables, and other objects.
USE ROLE SYSADMIN;

-- Set job_ads as the current database.
USE DATABASE job_ads;

-- Create a schema for transformed/final data produced by dbt.
-- IF NOT EXISTS prevents an error if the schema already exists.
CREATE SCHEMA IF NOT EXISTS marts;

-- Check that the marts schema was created.
SHOW SCHEMAS IN DATABASE job_ads;




