-- A) Use this database and find out the underlying schemas, tables and views to get an overview of its logical structure.
SHOW DATABASES;

-- to specify which db to use
USE GOOGLE_KEYWORDS;

-- Which schemas are inside this db?
SHOW SCHEMAS IN DATABASE GOOGLE_KEYWORDS;

-- Which tables are inside the DATAFEEDS schema?
SHOW TABLES IN SCHEMA GOOGLE_KEYWORDS.DATAFEEDS;


-- B) Find out the columns and its data types in the table GOOGLE_KEYWORDS.
-- Which columns does this table have, and what are their data types?
DESCRIBE TABLE GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS;

-- Small sample
SELECT *
FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
LIMIT 10;


--   C) Find out number of rows in the dataset. - 35046855
SELECT COUNT(*) AS total_rows
FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS;


--  D) When is the first search and when is the latest search in the dataset?
SELECT
    MIN (DATE) AS first_search,
    MAX (DATE) AS lastest_search
FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS;


--   E) Which are the 10 most popular keywords?
SELECT
    keyword,
    COUNT (*) AS number_of_searches
FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
GROUP BY keyword
ORDER BY number_of_searches
LIMIT 10;


--   F) How many unique keywords are there? - 7263686
SELECT COUNT(DISTINCT keyword) AS unique_keywords
FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS;


-- G) Check what type of platforms are used and how many users per platform - 111473
SELECT 
    platform,
    COUNT (DISTINCT calibrated_users) AS number_of_users
FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
GROUP BY platform
ORDER BY number_of_users DESC;

-- H) Let's dive into what swedish people are searching. Go into worldbanks country codes to find out the country code for Sweden. 
-- Find the 20 most popular keywords and the number of searches of that keyword. - Sweden is 752
SELECT 
    keyword,
    COUNT (*) AS number_of_searches
FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
WHERE country = 752
GROUP BY keyword
ORDER BY number_of_searches DESC
LIMIT 20;


-- I) Lets see how popular spotify is around the world. 
-- List the top 10 number countries and the number of searches for spotify.

SELECT
    country,
    COUNT (*) AS number_of_searches
FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
WHERE keyword = 'spotify'
GROUP BY country
ORDER BY number_of_searches DESC
LIMIT 10;