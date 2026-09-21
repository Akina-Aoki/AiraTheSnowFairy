/*
  d) Create a role marketing_dlt_role and grant it access to staging.
*/


-- USERADMIN is responsible for creating users and roles.
USE ROLE USERADMIN;

-- Create the role that dlt will use when loading marketing data.
CREATE ROLE IF NOT EXISTS marketing_dlt_role
    COMMENT = 'Role used by dlt to load marketing data into the staging schema';




/* Granting Access */

-- SECURITYADMIN manages grants and permissions.
USE ROLE SECURITYADMIN;

-- Allow the role to use the warehouse. Can use compute
GRANT USAGE ON WAREHOUSE marketing_wh
TO ROLE marketing_dlt_role;


-- Allow the role to access the database.
GRANT USAGE ON DATABASE ifood
TO ROLE marketing_dlt_role;


-- Allow the role to access the staging schema.
GRANT USAGE ON SCHEMA ifood.staging
TO ROLE marketing_dlt_role;


-- Allow dlt to create tables inside staging.
-- dlt can create the table where your marketing CSV will be loaded.
GRANT CREATE TABLE ON SCHEMA ifood.staging
TO ROLE marketing_dlt_role;





-- Allow CRUD operations on existing tables in staging.
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA ifood.staging
TO ROLE marketing_dlt_role;



-- Automatically give the same CRUD permissions
-- to tables created in staging in the future.
GRANT SELECT, INSERT, UPDATE, DELETE
ON FUTURE TABLES IN SCHEMA ifood.staging
TO ROLE marketing_dlt_role;