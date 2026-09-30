-- Reads the raw job ads source defined in sources.yml
-- and selects employer-related fields for a cleaner dbt model.


with stg_job_ads as (

    select *
    from {{ source('job_ads', 'stg_ads') }}
)

select
    employer_id,

    employer_name,

    employer_workplace,

    employer_organization_number,

    workplace_street_address,

    workplace_region,

    workplace_postcode,

    workplace_city,

    workplace_country

from stg_job_ads