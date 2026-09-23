/* Describe the Users Roles and Priviledges */

USE ROLE sysadmin;
USE SCHEMA public;

-- Select the warehouse to use for queries in this session.
USE WAREHOUSE dev_wh;

SELECT CURRENT_ROLE();

-- Check User
SELECT current_user();

SHOW warehouses;


DESCRIBE DATABASE job_ads;

DESCRIBE SCHEMA staging;
DESCRIBE SCHEMA warehouse;
DESCRIBE SCHEMA marts;


/* 

Snowflake Data Warehouse
Warehouse: COMPUTE_WH
Database: JOB_ADS
Schema: & Tables: 
    - INFORMATION SCHEMA
    - PUBLIC (NO query returned)
    - STAGING 
        - Tables (34)
    - WAREHOUSE
        - Tables (dim_occupation, fct_job_ads)
    - MARTS
        - marts_technical_jobs
 */

----------------------------------------------------------

/* Users 
- Service User:
    - extract_loader (for dlt)
    - transformer ( for dbt)

- Snowflake User:
    - AiraTheSnowFairy

Roles
- job_ads_dlt_role
- job_ads_dbt_role
*/


--------------------------------------------------
/*
Priviledges:
1. User: extract_loader (dlt), Roles: job_ads_dlt_role
    - Can work on the staging schema
- Usage of warehouse dev_wh / compute_wh
- Usage of database job_ads
- Usage of schema job_ads. staging
- Create table on schema job_ads.staging
- CRUD on ALL / FUTURE tables of schema job_ads.staging


2. User: transformer (dbt), Roles: dob_ads_dbt_role
    - Can work on warehouse & marts schema
- Usage of schema job_ads.warehouse
- Create table on schema job_ads.warehouse
- CRUD on ALL / FUTURE tables of schema job_ads.warehouse
- R (read) on ALL / FUTURE tables of schema job_ads.warehouse
 */
