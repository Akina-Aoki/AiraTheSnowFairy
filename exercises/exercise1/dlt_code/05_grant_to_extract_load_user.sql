/*   e) Assign marketing_dlt_role to extract_loader user.
extract_loader → marketing_dlt_role → access to marketing_wh + ifood.staging
*/

-- SECURITYADMIN manages role grants.
USE ROLE SECURITYADMIN;

-- Give the dlt loading role to the extract_loader user.
GRANT ROLE marketing_dlt_role
TO USER extract_loader;

-- Quick verification
SHOW GRANTS TO ROLE marketing_dlt_role;
SHOW TABLES IN SCHEMA ifood.staging;

SHOW FUTURE GRANTS TO ROLE marketing_dlt_role;