-- NOTE: you should .gitignore this file as it contains credentials
USE ROLE useradmin;

ALTER USER reporter
SET PASSWORD = 'OnigiriSuki123!!';


CREATE USER IF NOT EXISTS reporter
    PASSWORD = 'OnigiriSuki123!!' -- create and fill in password
    LOGIN_NAME = 'reporter'
    DEFAULT_WAREHOUSE = dev_wh
    DEFAULT_NAMESPACE = 'job_ads.marts'
    COMMENT = 'reporter user for making analysis and BI'
    DEFAULT_ROLE = 'job_ads_reporter_role';