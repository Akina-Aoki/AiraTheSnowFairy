-- Use USERADMIN because this role can create and manage users and roles.
USE ROLE USERADMIN;

-- Create a new role that dbt will use to transform data.
CREATE ROLE IF NOT EXISTS job_ads_dbt_role;


/* -  Role us created here. Now go to 01_setup_user.sql to setup the user settings
- Run GRANT ROLES below after setting up the user in 01_setup_user.sql */




-- Give the dbt role to the transformer user.
-- This allows the transformer user to use the permissions assigned to this role.
GRANT ROLE job_ads_dbt_role TO USER transformer;

-- Give the same dbt role to your personal Snowflake user.
-- Replace YOUR_USERNAME with your actual Snowflake username.
GRANT ROLE job_ads_dbt_role TO USER AIRATHESNOWFAIRY;