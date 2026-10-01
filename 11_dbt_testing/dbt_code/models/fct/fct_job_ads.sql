-- Builds a fact-style model from the cleaned src_job_ads model.
-- Data flow: Snowflake source -> sources.yml -> src_job_ads -> this model.
--
-- ref('src_job_ads') tells dbt that this model depends on src_job_ads.
-- dbt_utils.generate_surrogate_key() comes from the dbt_utils package,
-- which was installed with `dbt deps`.

with job_ads as (select * from {{ ref('src_job_ads') }}) -- upstream dbt model

select
    {{ dbt_utils.generate_surrogate_key(['occupation__label']) }} as occupation_id,
    {{ dbt_utils.generate_surrogate_key(['id']) }} as job_details_id,
    {{ dbt_utils.generate_surrogate_key(['employer__workplace', 'workplace_address__municipality']) }}
    as employer_id,
    vacancies,
    relevance,
    application_deadline
from job_ads
