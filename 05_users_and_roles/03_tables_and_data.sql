/*
SET UP THE SESSION
Choose the role, computing resources, and location for the tables.
*/

-- Use the writer role, which can create tables and modify data.
-- Your user must have been granted this role.
USE ROLE ice_cream_writer;

-- Select the warehouse that provides computing power for queries.
USE WAREHOUSE dev_wh;

-- Select the database and schema where we will work.
-- Tables referenced without a full path will use this location.
USE SCHEMA ice_cream_db.public;


-- Just for demo purposes so we can recreate the tables.
DROP TABLE flavors;

DROP TABLE customers;

DROP TABLE transactions;


/*
CREATE THE TABLES

Run these CREATE statements only if the tables do not already exist.
If you created them earlier, skip to the INSERT statements. or Drop first.
*/

-- Store one row for each ice cream flavor.
CREATE TABLE flavors (
    -- Generate an ID automatically when the INSERT omits this column.
    flavor_id INT AUTOINCREMENT,

    -- Store the flavor name as text.
    flavor_name STRING,

    -- Allow 5 digits in total, including 2 decimal places.
    -- Example: 2.50. Maximum positive value: 999.99.
    price DECIMAL(5, 2),

    -- Declare the intended unique identifier for each flavor.
    PRIMARY KEY (flavor_id)
);


-- Store one row for each customer.
CREATE TABLE customers (
    -- Generate an ID automatically for each new customer.
    customer_id INT AUTOINCREMENT,

    -- Store the customer's name and email as text.
    customer_name STRING,
    email STRING,

    -- Declare the intended unique identifier for each customer.
    PRIMARY KEY (customer_id)
);


-- Store one row for each purchase of a particular flavor.
CREATE TABLE transactions (
    -- Generate an ID automatically for each transaction.
    transaction_id INT AUTOINCREMENT,

    -- Identify which customer made the purchase.
    customer_id INT,

    -- Identify which flavor was purchased.
    flavor_id INT,

    -- Record the number of units purchased.
    quantity INT,

    -- Store the purchase date and time.
    transaction_date TIMESTAMP,

    -- Declare the intended unique identifier for each transaction.
    PRIMARY KEY (transaction_id),

    -- Describe the relationship to the customers table.
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id),

    -- Describe the relationship to the flavors table.
    FOREIGN KEY (flavor_id) REFERENCES flavors (flavor_id)
);


-- NOTE: In these standard Snowflake tables, PRIMARY KEY and
-- FOREIGN KEY constraints are not enforced.
-- You must check for duplicate IDs and invalid references yourself.






/*
INSERT SAMPLE DATA

INSERT INTO adds rows to an existing table.
The column list determines the order of the supplied values.
Each group of parentheses represents one row.
*/

-- Add five flavors and their prices.
-- flavor_id is omitted because AUTOINCREMENT generates it.
INSERT INTO flavors (flavor_name, price) VALUES
    ('Vanilla', 2.50),
    ('Chocolate', 2.75),
    ('Strawberry', 2.50),
    ('Mint Chocolate Chip', 3.00),
    ('Cookie Dough', 3.25);



-- Add three customers.
-- customer_id is generated automatically.
INSERT INTO customers (customer_name, email) VALUES
    ('John Doe', 'john.doe@example.com'),
    ('Jane Smith', 'jane.smith@example.com'),
    ('Alice Johnson', 'alice.johnson@example.com');



-- These sample transactions assume the customer IDs are 1–3
-- and the flavor IDs are 1–5.
-- Check the actual IDs first if the tables have been used before.
-- Automatically generated IDs can have gaps.

-- Add five purchases.
-- CURRENT_TIMESTAMP records the current date and time.
-- transaction_id is generated automatically.
INSERT INTO transactions (
    customer_id, flavor_id, quantity, transaction_date
) VALUES
    -- Customer 1 buys 2 units of flavor 1.
    (1, 1, 2, CURRENT_TIMESTAMP),

    -- Customer 2 buys 1 unit of flavor 2.
    (2, 2, 1, CURRENT_TIMESTAMP),

    -- Customer 3 buys 3 units of flavor 3.
    (3, 3, 3, CURRENT_TIMESTAMP),

    -- Customer 1 buys 1 unit of flavor 4.
    (1, 4, 1, CURRENT_TIMESTAMP),

    -- Customer 2 buys 2 units of flavor 5.
    (2, 5, 2, CURRENT_TIMESTAMP);




-- Read all columns and rows from flavors.
-- The asterisk (*) means "all columns".
SELECT * FROM flavors;
SELECT * FROM customers;



/*
TEST THE READER ROLE

The reader should be able to read data but not insert rows.
Run the following statements individually to observe the results.
*/

-- Switch the primary role to the reader.
-- Your user must be allowed to activate this role.
USE ROLE ice_cream_reader;

-- Disable secondary roles for this test.
-- Otherwise, another active role could supply INSERT permission,
-- making the insert succeed even while the primary role is reader.
USE SECONDARY ROLES NONE;

-- Check the primary role and any active secondary roles.
SELECT CURRENT_ROLE();
SELECT CURRENT_SECONDARY_ROLES();

-- This should succeed because the reader has SELECT permission.
SELECT * FROM customers;

-- This is an intentional permissions test.
-- It should fail because the reader has not been granted INSERT.
-- If it succeeds, the row is actually added to the table.
INSERT INTO customers (customer_name, email) VALUES
    ('John Doe2', 'john.doe@example.com');

-- Run this separately after the expected INSERT error.
-- Reading transactions should still succeed.
SELECT * FROM transactions;

-- NOTE: Running the sample INSERT statements again adds more rows.
-- They do not replace the data already in the tables.