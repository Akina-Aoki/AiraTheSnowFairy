-- Reads the raw job ads source defined in sources.yml
-- and selects occupation-related fields for a cleaner dbt model.

with stg_job_ads as (

    select *
    from {{ source('job_ads', 'stg_ads') }}

)

select

    occupation_group__concept_id as occupation_group_id,  -- group ID from source

    occupation_field__concept_id as occupation_field_id,  -- field ID from source

    occupation__label as occupation,                      -- occupation name

    occupation_group__label as occupation_group,          -- broader occupation group

    occupation_field__label as occupation_field           -- highest-level occupation field

from stg_job_ads