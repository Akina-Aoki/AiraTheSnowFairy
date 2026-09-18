-- Switch to SYSADMIN, a built-in role used to manage
-- objects such as databases, schemas, and warehouses.
USE ROLE SYSADMIN;

-- Create a database to hold the job advertisement data.
-- IF NOT EXISTS skips creation if job_ads already exists.
-- It does not delete or replace existing data.
CREATE DATABASE IF NOT EXISTS job_ads;

-- Create a staging schema inside the job_ads database.
-- This is where your dlt pipeline will load the job ads.
-- "staging" is a name we choose for the initial loading area;
-- it is a normal schema, not a special Snowflake object.
CREATE SCHEMA IF NOT EXISTS job_ads.staging;

-- CHeck DB here
DESCRIBE DATABASE job_ads;


-- ========================================
-- Go to 00_setup_user_role to assign more roles
-- ========================================