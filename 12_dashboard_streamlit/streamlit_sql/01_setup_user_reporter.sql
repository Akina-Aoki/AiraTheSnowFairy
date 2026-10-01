-- NOTE: you should .gitignore this file as it contains credentials
USE ROLE useradmin;

-- Password is managed separately and must never be committed to Git.
CREATE USER IF NOT EXISTS reporter
    LOGIN_NAME = 'reporter'
    DEFAULT_WAREHOUSE = dev_wh
    DEFAULT_NAMESPACE = 'job_ads.marts'
    COMMENT = 'reporter user for making analysis and BI'
    DEFAULT_ROLE = 'job_ads_reporter_role';