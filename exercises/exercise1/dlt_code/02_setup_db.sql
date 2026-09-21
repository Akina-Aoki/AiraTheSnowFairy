/*
  b) Now create a database called ifood, and add a staging layer by creating a schema called staging.
*/

-- Use SYSADMIN again because this is object creation.
USE ROLE SYSADMIN;

-- Create the database for the iFood project.
CREATE DATABASE IF NOT EXISTS ifood;

-- Use the ifood db 
USE DATABASE ifood;

-- Create the staging schema
CREATE SCHEMA IF NOT EXISTS staging;

-- Check the schema exists
SHOW SCHEMAS IN DATABASE ifood;