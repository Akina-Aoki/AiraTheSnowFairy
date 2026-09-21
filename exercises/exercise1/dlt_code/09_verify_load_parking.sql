/* Verify Load Parking API */

USE ROLE marketing_dlt_role;
USE WAREHOUSE marketing_wh;
USE DATABASE ifood;
USE SCHEMA staging;

SHOW TABLES LIKE 'PARKING%';

SELECT COUNT(*)
FROM parking_regulations;

SELECT *
FROM parking_regulations
LIMIT 10;