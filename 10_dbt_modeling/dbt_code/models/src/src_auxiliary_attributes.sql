-- Reads the raw job ads source defined in sources.yml
-- src_job_ads.sql is the source-cleaning model. 
-- It reads from the source defined in sources.yml, selects only the wanted columns, and renames one column.
with stg_job_ads as (

    select *
    from {{ source('job_ads', 'stg_ads') }}         -- dbt, go to the source called job_ads, then use the table called stg_ads

)

select
    id as job_ads_id,
    experience_required,
    driving_license_required as driver_license,
    access_to_own_car
from stg_job_ads