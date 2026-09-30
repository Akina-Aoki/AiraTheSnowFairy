-- Reads the raw job ads source defined in sources.yml
-- and selects employer-related fields for a cleaner dbt model.


with stg_job_ads as (

    select *
    from {{ source('job_ads', 'stg_ads') }}
)

select
    employer__name as employer_name,
    employer__workplace as employer_workplace,
    employer__organization_number as employer_organization_number,
    workplace_address__street_address as workplace_street_address,
    workplace_address__region as workplace_region,
    workplace_address__postcode as workplace_postcode,
    workplace_address__municipality as workplace_municipality,
    workplace_address__country as workplace_country
from stg_job_ads