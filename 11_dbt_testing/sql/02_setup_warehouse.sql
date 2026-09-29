-- ===== Create warehouse schema =====

-- Use SYSADMIN because it manages databases, schemas, tables, and views.
USE ROLE SYSADMIN;

-- Set job_ads as the current database.
USE DATABASE job_ads;

-- Create the warehouse schema where dbt will store transformed data.
CREATE SCHEMA IF NOT EXISTS warehouse;

-- Check that the warehouse schema exists.
SHOW SCHEMAS IN DATABASE job_ads;
