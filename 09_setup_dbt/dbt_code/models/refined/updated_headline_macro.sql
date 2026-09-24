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

-- Select the transformed job title
SELECT

    -- Run the custom dbt macro translate_headline()
    -- on the headline column, then rename the result to updated_job_title
    {{ translate_headline('headline') }} AS updated_job_title

-- Use the temporary staging_data result created above
FROM staging_data;