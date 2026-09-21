/*   e) Assign marketing_dlt_role to extract_loader user.
extract_loader → marketing_dlt_role → access to marketing_wh + ifood.staging
*/

-- SECURITYADMIN manages role grants.
USE ROLE SECURITYADMIN;

-- Give the dlt loading role to the extract_loader user.
GRANT ROLE marketing_dlt_role
TO USER extract_loader;

-- gIVE TO ME
GRANT ROLE marketing_dlt_role
TO USER AIRATHESNOWFAIRY;

-- Quick verification
SHOW GRANTS TO ROLE marketing_dlt_role;
SHOW TABLES IN SCHEMA ifood.staging;

SHOW FUTURE GRANTS TO ROLE marketing_dlt_role;




/* Grant priviledge to marketing_campaign */

USE ROLE SECURITYADMIN;
SELECT CURRENT_ROLE();
USE ROLE marketing_dlt_role;
SHOW TABLES IN SCHEMA ifood.staging;
SHOW GRANTS ON TABLE ifood.staging.marketing_campaign;


