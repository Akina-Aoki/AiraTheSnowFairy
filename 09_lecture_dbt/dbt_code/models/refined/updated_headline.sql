-- job_ads = database
-- staging = schema
-- data_field_job_ads = table


-- Create a temporary result called staging_data
WITH staging_data AS (

    -- Select all columns from the original_headline dbt model
    SELECT
        *

    -- ref() tells dbt to use the output of the original_headline model
    FROM {{ ref('original_headline') }}
)

-- Select and update the job title
SELECT

    -- CASE checks the value in the headline column
    CASE

        -- If the headline is exactly 'Data engineer',
        -- change it to 'Junior data engineer'
        WHEN headline = 'Data engineer' THEN 'Junior data engineer'

        -- Otherwise, keep the original headline
        ELSE headline

    -- Rename the final result column to job_title
    END AS job_title

-- Use the temporary staging_data result created above
FROM staging_data;