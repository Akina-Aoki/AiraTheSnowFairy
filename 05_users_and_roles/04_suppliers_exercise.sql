/* Class Question 1
Based on the lecture/code along sql worksheets:
1. using the ice_cream_writer role, create a new table under the public schema. This is a table called suppliers with the columns: supplier_id and supplier_name*/

-- Use the role required for this exercise.
USE ROLE ice_cream_writer;

-- Check which role is active
SELECT CURRENT_ROLE();

-- Select the compute warehouse used to run queries.
USE WAREHOUSE dev_wh;

-- Select the ice cream database.
USE DATABASE ice_cream_db;

-- Select the schema where we will create suppliers.
USE SCHEMA public;

-- Create the table in ice_cream_db.public.
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id INT,
    supplier_name STRING
);

-- SHow the table
DESCRIBE TABLE ice_cream_db.public.suppliers;


-- 2. As an object manager, can you use the role SYSADMIN to drop this table. Because we find out that this is a wrong table to be created

-- 3. by going through this step, can you conclude that our lecture/code along sql worksheets follows strictly the snowflake best practice of access control
USE ROLE SYSADMIN;

DROP TABLE suppliers;


/* Questio 2/reading
 -go to this link here: https://docs.snowflake.com/en/user-guide/security-access-control-considerations#example
- read the part: Aligning object access with business functions - Example
- check that if you understand the contents of this example and how they are compared with our presentation slide and code along example
*/

