-- ========================================
-- Set up a service user and role for dlt
--
-- User = the identity the pipeline signs in as.
-- Role = the permissions the pipeline can use.
-- ========================================


-- ACCOUNTADMIN can perform this setup, but has broad permissions.
-- For routine administration, USERADMIN can create users and roles,
-- and SECURITYADMIN can manage grants.
USE ROLE ACCOUNTADMIN;


-- Create the role used by the dlt loading pipeline.
-- IF NOT EXISTS leaves an existing role unchanged.
CREATE ROLE IF NOT EXISTS JOB_ADS_DLT_ROLE;


-- Create a user for an automated pipeline rather than a person.
--
-- Authentication uses a pair of keys:
-- Public key: stored in Snowflake.
-- Private key: used by your pipeline and kept secret.
--
-- Replace the placeholder with the public key from rsa_key.pub.
-- Remove the BEGIN/END headers and join the key into one line.
--
-- IMPORTANT: If extract_loader already exists, this statement
-- skips creation. It does NOT update the user's key or settings.
CREATE USER IF NOT EXISTS extract_loader
    TYPE = SERVICE
    RSA_PUBLIC_KEY = '<YOUR_PUBLIC_KEY_STRING_HERE>'
    DEFAULT_ROLE = JOB_ADS_DLT_ROLE
    DEFAULT_WAREHOUSE = DEV_WH
    COMMENT = 'Service user for dlt pipeline';

-- DEFAULT_ROLE chooses the starting role for a connection.
-- It does not grant that role to the user.
--
-- DEFAULT_WAREHOUSE chooses the starting warehouse.
-- It does not grant permission to use that warehouse.


-- Inspect the user's settings.
-- DESC is short for DESCRIBE.
DESC USER extract_loader;


-- Allow the service user to use the dlt role.
GRANT ROLE JOB_ADS_DLT_ROLE TO USER extract_loader;

-- Optional: allow your own Snowflake user to use this role
-- when testing or troubleshooting.
-- Replace YOUR_USERNAME before uncommenting and running.
-- GRANT ROLE JOB_ADS_DLT_ROLE TO USER YOUR_USERNAME;


-- Place the custom role under SYSADMIN in the role hierarchy.
-- SYSADMIN inherits the privileges of JOB_ADS_DLT_ROLE.
-- JOB_ADS_DLT_ROLE does NOT inherit SYSADMIN's privileges.
GRANT ROLE JOB_ADS_DLT_ROLE TO ROLE SYSADMIN;


-- ========================================
-- Grant access to compute and storage
-- ========================================

-- Allow the role to use dev_wh for computing work.
GRANT USAGE ON WAREHOUSE dev_wh
TO ROLE job_ads_dlt_role;

-- Allow access to the database.
-- This alone does not allow reading its tables.
GRANT USAGE ON DATABASE job_ads
TO ROLE job_ads_dlt_role;

-- Allow access to the staging schema inside job_ads.
-- Table permissions are granted separately below.
GRANT USAGE ON SCHEMA job_ads.staging
TO ROLE job_ads_dlt_role;

-- Allow dlt to create tables inside the staging schema.
GRANT CREATE TABLE ON SCHEMA job_ads.staging
TO ROLE job_ads_dlt_role;


-- ========================================
-- Grant permissions on table data
-- ========================================

-- Give permissions on tables that already exist:
-- SELECT = read rows.
-- INSERT = add rows.
-- UPDATE = change existing rows.
-- DELETE = remove rows, without deleting the table itself.
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA job_ads.staging
TO ROLE job_ads_dlt_role;

-- Automatically give the same permissions on tables
-- created in this schema in the future.
-- This does not create any tables.
GRANT SELECT, INSERT, UPDATE, DELETE
ON FUTURE TABLES IN SCHEMA job_ads.staging
TO ROLE job_ads_dlt_role;