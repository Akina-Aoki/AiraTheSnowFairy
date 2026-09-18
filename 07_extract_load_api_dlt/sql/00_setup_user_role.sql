-- Keep the CREATE USER statement in a separate SQL file
-- because it contains a password.
-- Add that file to .gitignore before committing to GitHub.
-- .gitignore does not protect files Git already tracks.


-- ========================================
-- 1. Create the role and user
-- ========================================

-- USERADMIN can create users and roles.
USE ROLE USERADMIN;


-- Create the identity the pipeline will use to sign in.
-- Replace the empty string with your password.
--
-- DEFAULT_WAREHOUSE chooses the starting compute warehouse.
-- It does not give the user permission to use that warehouse.
--
-- If extract_loader already exists, this statement does nothing:
-- it does not change the password or other user settings.
CREATE USER IF NOT EXISTS extract_loader
    PASSWORD = 'OnigiriSuki123!' -- Enter your password here.
    DEFAULT_WAREHOUSE = dev_wh;


-- ========================================
-- Proceed to 01_setup_databse to set DB and schema
-- ========================================

-- ========================================
-- 2. Assign the role to the user
-- ========================================

-- Create a role to hold the dlt pipeline's permissions.
-- If the role already exists, leave it unchanged.
CREATE ROLE IF NOT EXISTS job_ads_dlt_role;



-- SECURITYADMIN can manage access permissions and role grants.
USE ROLE SECURITYADMIN;

-- Allow extract_loader to use the permissions in this role.
-- This does not set the user's default role.
GRANT ROLE job_ads_dlt_role TO USER extract_loader;


-- ========================================
-- assign the role to yourself
-- ========================================

-- This lets you test the pipeline's permissions using your own login.
-- Replace YOUR_USERNAME, then uncomment the statement.
-- GRANT ROLE job_ads_dlt_role TO USER YOUR_USERNAME;
GRANT ROLE job_ads_dlt_role TO USER AiraTheSnowFairy;


-- ========================================
-- 3. Grant access to the warehouse and schema
-- ========================================

-- Allow the role to use the warehouse's computing power.
GRANT USAGE ON WAREHOUSE dev_wh
TO ROLE job_ads_dlt_role;

-- Allow access to the job_ads database.
-- Access to its schemas and tables requires separate grants.
GRANT USAGE ON DATABASE job_ads
TO ROLE job_ads_dlt_role;

-- Allow access to the staging schema inside job_ads.
-- USAGE alone does not allow reading or changing table data.
GRANT USAGE ON SCHEMA job_ads.staging
TO ROLE job_ads_dlt_role;

-- Allow the pipeline to create tables in this schema.
GRANT CREATE TABLE ON SCHEMA job_ads.staging
TO ROLE job_ads_dlt_role;


-- ========================================
-- 4. Grant permissions on table data CRUD OPS
-- ========================================

-- Grant permissions on tables that already exist:
-- SELECT: read rows.
-- INSERT: add rows.
-- UPDATE: change existing rows.
-- DELETE: remove rows.
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA job_ads.staging
TO ROLE job_ads_dlt_role;

-- Automatically grant the same permissions on new tables
-- created in this schema later.
-- FUTURE does not apply these permissions to existing tables,
-- which is why we have both statements.
GRANT SELECT, INSERT, UPDATE, DELETE
ON FUTURE TABLES IN SCHEMA job_ads.staging
TO ROLE job_ads_dlt_role;


-- ========================================
-- 5. Inspect the permissions
-- ========================================

-- Show grants on the schema itself, such as USAGE and CREATE TABLE.
-- This does not list the grants on every table inside it.
SHOW GRANTS ON SCHEMA job_ads.staging;

-- Show automatic grant rules for future objects in this schema.
SHOW FUTURE GRANTS IN SCHEMA job_ads.staging;

-- Show privileges and roles granted directly to the dlt role.
SHOW GRANTS TO ROLE job_ads_dlt_role;

-- Show roles assigned to the pipeline's user.
SHOW GRANTS TO USER extract_loader;


-- ========================================
-- Start with EDA in ntbk
-- ========================================