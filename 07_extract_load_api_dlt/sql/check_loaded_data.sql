-- Use the role that has permission to access the job ads data.
-- A role determines which actions you are allowed to perform.
USE ROLE job_ads_dlt_role;

-- Set job_ads as the current database.
-- Schema and table names below will refer to this database.
USE DATABASE job_ads;


-- List the schemas in the current database that your role can see.
-- A schema is a container for objects such as tables and views.
SHOW SCHEMAS;

-- List the tables your role can see inside the staging schema.
SHOW TABLES IN SCHEMA staging;

-- Describe the table's structure without reading its rows.
-- Shows column names, data types, and other column details.
-- DESC is short for DESCRIBE.
DESC TABLE staging.data_field_job_ads;


-- Select the warehouse that will provide computing power
-- to run the SELECT queries below.
-- The warehouse processes queries; it does not store the table.
USE WAREHOUSE dev_wh;

-- Read two columns from the job ads table:
-- headline: the job advertisement's title.
-- employer__workplace: the employer's workplace field.
--
-- dlt uses double underscores when flattening nested fields:
-- employer → workplace becomes employer__workplace.
SELECT
    headline,
    employer__workplace
FROM staging.data_field_job_ads;


-- Read every column and every row from the table.
-- The asterisk (*) means "all columns".
-- For a quick preview, add LIMIT 10 before the semicolon.
SELECT *
FROM staging.data_field_job_ads;