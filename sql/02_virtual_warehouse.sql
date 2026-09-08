-- Create a virtual warehouse. Youtube video on 04_what_is_snowflake
SHOW WAREHOUSES;

CREATE WAREHOUSE demo_warehouse
WITH
WAREHOUSE_SIZE = 'X-Small'
AUTO_SUSPEND = 300
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
COMMENT = 'Demo warehouse created through sql worksheet.';


SHOW WAREHOUSES;

/* DDL OPERATIONS TO MODIFY THE WAREHOUSE
Automatically pause COMPUTE_WH after 60 seconds of inactivity to save compute credits. */
ALTER WAREHOUSE COMPUTE_WH
SET AUTO_SUSPEND = 60;



-- A cluster is a group of computing resources that work together to run queries.
-- Allow up to 3 clusters so more queries can run at the same time.
-- Requires Enterprise Edition or higher.
ALTER WAREHOUSE DEMO_WAREHOUSE
SET MAX_CLUSTER_COUNT = 3;


DROP WAREHOUSE DEMO_WAREHOUSE;

SHOW WAREHOUSES;