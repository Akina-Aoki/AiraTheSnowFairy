

-- Switch to SECURITYADMIN to manage permissions and grants.
USE ROLE SECURITYADMIN;

-- Allow the dbt role to access the marts schema
-- and create tables and views inside it.
GRANT USAGE,
CREATE TABLE,
CREATE VIEW 
ON SCHEMA job_ads.marts 
TO ROLE job_ads_dbt_role;


-- Give the dbt role permission to work with existing tables in marts.
GRANT SELECT,
INSERT,
UPDATE,
DELETE 
ON ALL TABLES IN SCHEMA job_ads.marts 
TO ROLE job_ads_dbt_role;

-- Allow the dbt role to read existing views in marts.
GRANT SELECT 
ON ALL VIEWS IN SCHEMA job_ads.marts 
TO ROLE job_ads_dbt_role;


-- Give the same permissions automatically to tables created in the future.
GRANT SELECT,
INSERT,
UPDATE,
DELETE 
ON FUTURE TABLES IN SCHEMA job_ads.marts 
TO ROLE job_ads_dbt_role;

-- Allow the dbt role to read views created in the future.
GRANT SELECT 
ON FUTURE VIEWS IN SCHEMA job_ads.marts 
TO ROLE job_ads_dbt_role;






-- Switch to the dbt role to test its permissions.
USE ROLE job_ads_dbt_role;

-- Check which permissions have been granted on the marts schema.
SHOW GRANTS ON SCHEMA job_ads.marts;


-- ===== Manual test =====

-- Use the marts schema.
USE SCHEMA job_ads.marts;

-- Test if the dbt role can create a table.
CREATE TABLE test (id INTEGER);

-- Check that the test table was created.
SHOW TABLES;

-- Delete the test table after confirming that the permissions work.
DROP TABLE test;