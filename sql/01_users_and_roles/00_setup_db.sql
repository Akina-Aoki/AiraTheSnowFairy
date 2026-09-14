-- Switch to the SYSADMIN role.
-- A role determines what you are allowed to do in Snowflake.
-- SYSADMIN can create databases, warehouses, and other objects.
USE ROLE SYSADMIN;

-- Check which role your session is using.
SELECT CURRENT_ROLE();

-- Check User
SELECT current_user();

-- Create a database called ice_cream_db.
-- A database stores and organizes objects such as schemas and tables.
CREATE DATABASE IF NOT EXISTS ice_cream_db;

SHOW warehouses;

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


-- Explicitly select where the tables below will be created.
-- PUBLIC is a schema automatically created inside a new database.
-- A schema groups related objects, such as tables.
USE DATABASE ice_cream_db;
USE SCHEMA public;

-- Select the warehouse to use for queries in this session.
USE WAREHOUSE dev_wh;


/*
TABLE: flavors
Stores the ice cream flavors available for sale.
Each row represents one flavor.
*/
CREATE TABLE flavors (
    -- Automatically generate a numeric ID when an insert omits this column.
    -- IDs may have gaps; they are not guaranteed to be consecutive.
    flavor_id INT AUTOINCREMENT,

    -- Store the flavor's name as text, such as 'Vanilla'.
    flavor_name STRING,

    -- Store the price as an exact decimal number.
    -- DECIMAL(5, 2) allows 5 digits in total, with 2 after the decimal point.
    -- Example: 125.50. The largest positive value is 999.99.
    price DECIMAL(5, 2),

    -- Declare flavor_id as the intended unique identifier for each row.
    PRIMARY KEY (flavor_id)
);


/*
TABLE: customers
Stores information about customers.
Each row represents one customer.
*/
CREATE TABLE customers (
    -- Automatically generate a numeric ID for a new customer.
    customer_id INT AUTOINCREMENT,

    -- Store the customer's name as text.
    customer_name STRING,

    -- Store the customer's email address as text.
    -- STRING does not check whether the email address is valid.
    email STRING,

    -- Declare customer_id as the intended unique identifier for each row.
    PRIMARY KEY (customer_id)
);


/*
TABLE: transactions
Stores purchases and connects customers to ice cream flavors.

Each row records one customer buying a quantity of one flavor.
The customer and flavor details are stored in their own tables.
Their IDs let us connect the tables using JOIN queries.
*/
CREATE TABLE transactions (
    -- Automatically generate an ID for each transaction row.
    transaction_id INT AUTOINCREMENT,

    -- Store the ID of the customer making the purchase.
    customer_id INT,

    -- Store the ID of the flavor being purchased.
    flavor_id INT,

    -- Store the number of units purchased, such as 2.
    quantity INT,

    -- Store the date and time of the purchase.
    -- This does not automatically record the current time;
    -- a value must be supplied when inserting the transaction.
    transaction_date TIMESTAMP,

    -- Declare transaction_id as the intended unique identifier.
    PRIMARY KEY (transaction_id),

    -- Describe the relationship between this transaction and a customer.
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id),

    -- Describe the relationship between this transaction and a flavor.
    FOREIGN KEY (flavor_id) REFERENCES flavors (flavor_id)
);