/* verify the Snowflake table and data */

-- Check where I am first
SELECT CURRENT_USER(), CURRENT_ROLE();

USE ROLE SECURITYADMIN;

-- Grant to me
GRANT ROLE marketing_dlt_role
TO USER AIRATHESNOWFAIRY;

USE ROLE marketing_dlt_role;
USE WAREHOUSE marketing_wh;
USE DATABASE ifood;
USE SCHEMA staging;

SHOW TABLES;
SHOW TABLES IN SCHEMA ifood.staging;
SHOW GRANTS ON TABLE ifood.staging.marketing_campaigns;


-- Verify the actual tables and data

SELECT COUNT(*)
FROM ifood.staging.marketing_campaigns;


-- Show 10
SELECT *
FROM ifood.staging.marketing_campaigns
LIMIT 10;


-- More other tests
USE ROLE marketing_dlt_role;
USE WAREHOUSE marketing_wh;
USE DATABASE ifood;
USE SCHEMA staging;

SELECT
    CURRENT_USER(),
    CURRENT_ROLE(),
    CURRENT_DATABASE(),
    CURRENT_SCHEMA(),
    CURRENT_WAREHOUSE();


SELECT
    grantee,
    privilege_type,
    table_name
FROM ifood.information_schema.table_privileges
WHERE table_schema = 'STAGING'
  AND table_name = 'MARKETING_CAMPAIGNS';



SELECT COUNT(*)
FROM marketing_campaigns;