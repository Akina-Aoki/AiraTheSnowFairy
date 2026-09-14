-- Switch to the role used to read the movies data.
-- This role must have permission to access the objects below.
USE ROLE movies_reader;

-- Select the database we want to work with.
USE DATABASE movies;

-- List the schemas in this database that your role can see.
-- Schemas are containers that organize tables and other objects.
SHOW SCHEMAS;

-- Select the staging schema where the pipeline loaded the data.
USE SCHEMA staging;

-- List the tables in the current schema that your role can see.
SHOW TABLES;

-- Select the warehouse that provides computing power for queries.
USE WAREHOUSE dev_wh;

-- Display all columns and rows from the netflix table.
-- With the database and schema selected above,
-- netflix refers to movies.staging.netflix.
SELECT * FROM netflix;

-- Show the table's structure, including column names and data types.
-- DESC is short for DESCRIBE.
DESC TABLE netflix;

-- Count the total number of rows in the table.
SELECT COUNT(*) FROM netflix;