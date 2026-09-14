-- Switch to the SYSADMIN role.
-- A role determines what you are allowed to do in Snowflake.
-- SYSADMIN can create databases, warehouses, and other objects.
USE ROLE SYSADMIN;

-- Check which role your session is using.
SELECT CURRENT_ROLE();

-- Check User
SELECT current_user();


-- Create a virtual warehouse called dev_wh.
-- A warehouse provides the computing power needed to run queries.
-- It does not store the table data.
CREATE WAREHOUSE dev_wh
WITH
    -- XSMALL is the smallest standard warehouse size.
    WAREHOUSE_SIZE = 'XSMALL'

    -- Automatically pause the warehouse after 60 seconds of inactivity.
    -- This helps reduce compute costs.
    AUTO_SUSPEND = 60

    -- Automatically start the warehouse when a query needs it.
    AUTO_RESUME = TRUE

    -- Create the warehouse in a paused state.
    -- It will start when needed.
    INITIALLY_SUSPENDED = TRUE

    -- Save a description of the warehouse for other users to read.
    COMMENT = 'Warehouse for development and analysis database.';


SHOW warehouses;
