-- ===== Create warehouse schema =====

-- Use SYSADMIN because it manages databases, schemas, tables, and views.
USE ROLE SYSADMIN;

-- Set job_ads as the current database.
USE DATABASE job_ads;

-- Create the warehouse schema where dbt will store transformed data.
CREATE SCHEMA IF NOT EXISTS warehouse;

-- Check that the warehouse schema exists.
SHOW SCHEMAS IN DATABASE job_ads;


-- ===== Grant permissions to the dbt role =====

-- Use SECURITYADMIN because this role manages roles and privileges.
USE ROLE SECURITYADMIN;

-- Give the dbt role the dlt role.
-- This means job_ads_dbt_role inherits the permissions of job_ads_dlt_role,
-- including access to the staging data loaded by dlt.
GRANT ROLE job_ads_dlt_role TO ROLE job_ads_dbt_role;

-- Show privileges and roles granted TO the dbt role.
SHOW GRANTS TO ROLE job_ads_dbt_role;

-- Show which users or roles have been granted the dbt role.
SHOW GRANTS OF ROLE job_ads_dbt_role;


-- Allow the dbt role to access the warehouse schema
-- and create tables and views inside it.
GRANT USAGE,
CREATE TABLE,
CREATE VIEW
ON SCHEMA job_ads.warehouse
TO ROLE job_ads_dbt_role;

-- job_ads_dbt_role inherits database access from job_ads_dlt_role.


-- ===== Permissions for existing objects =====

-- Allow dbt to read and modify existing tables in the warehouse schema.
GRANT SELECT,
INSERT,
UPDATE,
DELETE
ON ALL TABLES IN SCHEMA job_ads.warehouse
TO ROLE job_ads_dbt_role;

-- Allow dbt to read existing views.
GRANT SELECT
ON ALL VIEWS IN SCHEMA job_ads.warehouse
TO ROLE job_ads_dbt_role;


-- ===== Permissions for future objects =====

-- Automatically give the same permissions to future tables.
GRANT SELECT,
INSERT,
UPDATE,
DELETE
ON FUTURE TABLES IN SCHEMA job_ads.warehouse
TO ROLE job_ads_dbt_role;

-- Automatically allow the dbt role to read future views.
GRANT SELECT
ON FUTURE VIEWS IN SCHEMA job_ads.warehouse
TO ROLE job_ads_dbt_role;


-- ===== Test the dbt role =====

-- Switch to the role that dbt will use.
USE ROLE job_ads_dbt_role;

-- Test that the dbt role can read data from the staging schema.
SELECT *
FROM job_ads.staging.data_field_job_ads
LIMIT 10;

-- Check the permissions granted on the warehouse schema.
SHOW GRANTS ON SCHEMA job_ads.warehouse;


-- ===== Manual create-table test =====

-- Set the warehouse schema as the current schema.
USE SCHEMA job_ads.warehouse;

-- Test whether the dbt role can create a table.
CREATE TABLE test (id INTEGER);

-- Check that the table was successfully created.
SHOW TABLES;

-- Check the dbt role's current privileges again.
SHOW GRANTS TO ROLE job_ads_dbt_role;

-- Remove the test table after confirming that everything works.
DROP TABLE test;