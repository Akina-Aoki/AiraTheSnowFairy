/*
PURPOSE
Create roles and give them different levels of access.

reader  = read table data
writer  = inherit reader access, modify data, and create tables
analyst = created here, but its permissions are not assigned yet

The database and warehouse from the previous script must already exist.
*/


-- Switch to USERADMIN, which can create and manage users and roles.
USE ROLE USERADMIN;

-- Show the primary role currently active in this session.
SELECT CURRENT_ROLE();

-- Show the user account you are logged in with.
-- Switching roles does not change the logged-in user.
SELECT CURRENT_USER();


/*
CREATE THREE CUSTOM ROLES

Creating a role does not automatically give it permissions.
The COMMENT describes its intended purpose; it does not grant access.
*/

CREATE ROLE ice_cream_reader
    COMMENT = 'Able to read ice_cream database';



-- CRUD means:
-- Create = insert new rows
-- Read   = query rows using SELECT
-- Update = change existing rows
-- Delete = remove rows
CREATE ROLE ice_cream_writer
    COMMENT = 'Able to do CRUD operations on ice_cream database';




-- This role is only created in this script.
-- It still needs permissions before it can create views.
CREATE ROLE ice_cream_analyst
    COMMENT = 'Able to create views on ice_cream database';


SHOW ROLES;

/*
GIVE THE READER ROLE ACCESS

To query a table, the role needs access to:
1. A warehouse to run the query.
2. The database containing the table.
3. The schema containing the table.
4. The table data itself.
*/

-- SECURITYADMIN can manage privilege grants across the account.
USE ROLE SECURITYADMIN;



-- Allow the reader to use this warehouse's computing power.
-- This does not give permission to change its size or settings.
GRANT USAGE ON WAREHOUSE dev_wh
    TO ROLE ice_cream_reader;



-- Allow access to the database.
-- This alone does not allow the role to read its tables.
GRANT USAGE ON DATABASE ice_cream_db
    TO ROLE ice_cream_reader;



-- Allow access to all schemas currently inside this database.
-- A schema is a container for tables, views, and other objects.
-- This does not grant access to the data inside those objects.
-- It also does not cover schemas created later.
GRANT USAGE ON ALL SCHEMAS IN DATABASE ice_cream_db
    TO ROLE ice_cream_reader;



-- Allow SELECT queries on all tables that already exist in PUBLIC.
-- SELECT means reading data without changing it.
GRANT SELECT ON ALL TABLES IN SCHEMA ice_cream_db.public
    TO ROLE ice_cream_reader;



-- Automatically grant SELECT on new tables created later in PUBLIC.
-- This is why we use both ALL TABLES and FUTURE TABLES:
-- ALL covers existing tables; FUTURE covers tables created later.
GRANT SELECT ON FUTURE TABLES IN SCHEMA ice_cream_db.public
    TO ROLE ice_cream_reader;




-- Inspect the permissions directly granted to the reader role.
SHOW GRANTS TO ROLE ice_cream_reader;




-- Inspect the rules that will grant permissions on future objects
-- in PUBLIC. Results can include grants for multiple roles.
-- ASK ABOUT THE RESULTS??? = Query produced no results
SHOW FUTURE GRANTS IN SCHEMA ice_cream_db.public;


/*
ROLE INHERITANCE

Give the reader role to the writer role.

The writer inherits the reader's permissions, including SELECT
and access to the warehouse, database, and schemas.

The reader does not inherit the writer's permissions.
*/
GRANT ROLE ice_cream_reader
    TO ROLE ice_cream_writer;

-- Inspect grants made directly to the writer role.
-- This is not a complete list of its inherited permissions.
SHOW GRANTS TO ROLE ice_cream_writer;



/*
GIVE THE WRITER ADDITIONAL PERMISSIONS

The writer already inherits SELECT from the reader.
Now add permission to insert, update, and delete rows.
*/

-- Allow changes to data in all existing tables in PUBLIC:
-- INSERT = add new rows.
-- UPDATE = change existing rows.
-- DELETE = remove rows, while keeping the table itself.
GRANT INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA ice_cream_db.public
    TO ROLE ice_cream_writer;



-- Automatically give the same permissions on tables created later (future tables in schema).
GRANT INSERT, UPDATE, DELETE
    ON FUTURE TABLES IN SCHEMA ice_cream_db.public
    TO ROLE ice_cream_writer;



-- Allow the writer to create new tables inside PUBLIC.
-- Creating a table is different from inserting rows into a table.
GRANT CREATE TABLE ON SCHEMA ice_cream_db.public
    TO ROLE ice_cream_writer;

-- Check what ice_cream_writer can do NOW
SHOW GRANTS TO ROLE ice_cream_writer;

-- Check the future-grant rules again after adding writer permissions.
SHOW FUTURE GRANTS IN SCHEMA ice_cream_db.public;




/*
ASSIGN THE WRITER ROLE TO A USER (real person)
*/

-- Allow the existing user ME (AIRATHESNOWFAIRY) to use the writer role,
-- including the reader permissions it inherits.
-- Replace kokchun with your Snowflake username when appropriate.
-- This does not automatically switch the user's active role.

USE ROLE USERADMIN;
GRANT ROLE ice_cream_writer TO USER AIRATHESNOWFAIRY;