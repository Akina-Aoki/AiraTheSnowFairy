/*
 a) Create a marketing virtual warehouse called marketing_wh with size xs, 1 min suspend time, 
 it should autoresume, suspend initially and give it a suitable comment.
 */

-- Use the system role responsible for creating warehouse
USE ROLE SYSADMIN;


-- Create the marketing WH
CREATE WAREHOUSE IF NOT EXISTS marketing_wh
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for marketing data workloads';


-- Check if wh is created
SHOW WAREHOUSES LIKE 'MARKETING_WH';


