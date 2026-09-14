-- Switch to SYSADMIN, which can create databases and other objects.
USE ROLE sysadmin;

-- Create the movies database to hold our schemas and tables.
-- IF NOT EXISTS skips creation if the database already exists.
-- It does not delete or replace existing data.
CREATE DATABASE IF NOT EXISTS movies;

-- Create the staging schema inside the movies database.
-- We use staging as a landing zone for newly loaded data,
-- before cleaning or transforming it.
-- IF NOT EXISTS skips creation if this schema already exists.
CREATE SCHEMA IF NOT EXISTS movies.staging;