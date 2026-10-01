-- IMPORTANT:
-- This file contains authentication-related information.
-- Add it to .gitignore so it is not pushed to GitHub.

-- Use USERADMIN because this role can create and manage users.
USE ROLE USERADMIN;

-- Create a service user for the dbt pipeline.
-- TYPE = SERVICE means this user is intended for an application,
-- not for a person logging in manually.
CREATE USER IF NOT EXISTS transformer
    TYPE = SERVICE

    -- Public key used to authenticate the dbt service user.
    -- Replace this placeholder with your actual RSA public key.
    RSA_PUBLIC_KEY = '<YOUR_PUBLIC_KEY_STRING_HERE>'

    -- Set the default role used when this user connects.
    DEFAULT_ROLE = JOB_ADS_DBT_ROLE

    -- Set the default warehouse used for running dbt queries.
    DEFAULT_WAREHOUSE = DEV_WH

    -- Description of what this user is used for.
    COMMENT = 'Service user for dbt pipeline';