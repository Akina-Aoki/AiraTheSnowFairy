-- Reads the raw job ads source defined in sources.yml
-- src_job_ads.sql is the source-cleaning model. 
-- It reads from the source defined in sources.yml, selects only the wanted columns, and renames one column.
with stg_job_ads as (

    select *
    from {{ source('job_ads', 'stg_ads') }}         -- dbt, go to the source called job_ads, then use the table called stg_ads

)

select

    occupation__label,

    number_of_vacancies as vacancies,  -- rename to a simpler column name

    relevance,

    application_deadline

from stg_job_ads

order by application_deadline