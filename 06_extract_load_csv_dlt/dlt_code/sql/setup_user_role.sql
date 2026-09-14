-- IMPORTANT:
-- Keep the CREATE USER statement in a separate SQL file
-- because it contains a password.
-- Add that file to .gitignore before committing to GitHub.


-- ===== 1. Create the loading role and user =====

-- USERADMIN can create users and roles.
USE ROLE USERADMIN;

-- Create a role for the dlt pipeline.
-- We will give this role permission to load data into Snowflake.
CREATE ROLE IF NOT EXISTS movies_dlt_role;

-- Create a separate user for the dlt pipeline to sign in with.
-- Replace the empty password before running this statement.
-- DEFAULT_WAREHOUSE sets the user's default compute warehouse;
-- it does not give permission to use that warehouse.
-- IF NOT EXISTS skips creation if the user already exists.
CREATE USER IF NOT EXISTS extract_loader
    PASSWORD = '' -- Enter your password here.
    DEFAULT_WAREHOUSE = dev_wh;


-- ===== 2. Assign the loading role to the user =====

-- SECURITYADMIN can manage grants:
-- assigning roles and giving roles access to objects.
USE ROLE SECURITYADMIN;

-- Allow extract_loader to use movies_dlt_role.
GRANT ROLE movies_dlt_role TO USER extract_loader;


-- ===== 3. Give the loading role access =====

-- Allow the role to use the warehouse's computing power.
GRANT USAGE ON WAREHOUSE dev_wh
    TO ROLE movies_dlt_role;

-- Allow access to the movies database.
-- USAGE alone does not allow reading or changing table data.
GRANT USAGE ON DATABASE movies
    TO ROLE movies_dlt_role;

-- Allow access to the staging schema inside movies.
GRANT USAGE ON SCHEMA movies.staging
    TO ROLE movies_dlt_role;

-- Allow the pipeline to create tables in staging.
GRANT CREATE TABLE ON SCHEMA movies.staging
    TO ROLE movies_dlt_role;

-- Allow changes to all EXISTING tables in staging:
-- INSERT = add rows.
-- UPDATE = change existing rows.
-- DELETE = remove rows.
GRANT INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA movies.staging
    TO ROLE movies_dlt_role;

-- Automatically give the same permissions on NEW tables
-- created in staging after this grant.
GRANT INSERT, UPDATE, DELETE
    ON FUTURE TABLES IN SCHEMA movies.staging
    TO ROLE movies_dlt_role;


-- ===== 4. Check the assigned permissions =====

-- Show permissions granted on the staging schema itself.
-- This does not list permissions on individual tables inside it.
SHOW GRANTS ON SCHEMA movies.staging;

-- Show permissions configured for future objects in staging.
SHOW FUTURE GRANTS IN SCHEMA movies.staging;

-- Show the permissions and roles granted to movies_dlt_role.
SHOW GRANTS TO ROLE movies_dlt_role;

-- Show the roles assigned to the extract_loader user.
SHOW GRANTS TO USER extract_loader;


-- ===== 5. Create a role for reading data =====

USE ROLE USERADMIN;

-- Create a role for querying data.
CREATE ROLE IF NOT EXISTS movies_reader;


-- ===== 6. Give the reader role access =====

USE ROLE SECURITYADMIN;

-- Allow the reader to use the warehouse to run queries.
GRANT USAGE ON WAREHOUSE dev_wh
    TO ROLE movies_reader;

-- Allow access to the movies database.
GRANT USAGE ON DATABASE movies
    TO ROLE movies_reader;

-- Allow access to the staging schema.
GRANT USAGE ON SCHEMA movies.staging
    TO ROLE movies_reader;

-- Allow reading all EXISTING tables in staging.
-- SELECT does not allow adding, changing, or deleting rows.
GRANT SELECT ON ALL TABLES IN SCHEMA movies.staging
    TO ROLE movies_reader;

-- Configure read access for FUTURE tables across the movies database.
-- This is broader than staging: it also covers other schemas.
-- The role still needs USAGE on a schema to access its tables.
GRANT SELECT ON FUTURE TABLES IN DATABASE movies
    TO ROLE movies_reader;

-- Assign the reader role to your own Snowflake user.
-- Replace YOUR_USERNAME with your actual username before running.
GRANT ROLE movies_reader TO USER YOUR_USERNAME;