-- Builds a cleaned occupation dimension from the src_occupation dbt model.
-- src_occupation itself comes from the source table defined in sources.yml,
-- so the data flow is: Snowflake source -> src_occupation -> this model.
--
-- ref() is dbt's own function.
-- ref('src_occupation') tells dbt that this model depends on src_occupation.
-- dbt_utils.generate_surrogate_key() comes from the dbt_utils package
-- installed with `dbt deps` and creates a stable generated ID.

with src_job_details as (

    select *
    from {{ ref('src_job_details') }}

)

select

    job_details_id,

    headline,

    description,

    description_html_formatted,

    employment_type,

    duration,

    salary_type,

    scope_of_work_min,

    scope_of_work_max

from stg_job_ads

order by job_details_id