-- Builds a fact-style model from the cleaned src_job_ads model.
-- Data flow: Snowflake source -> sources.yml -> src_job_ads -> this model.
--
-- ref('src_job_ads') tells dbt that this model depends on src_job_ads.
-- dbt_utils.generate_surrogate_key() comes from the dbt_utils package,
-- which was installed with `dbt deps`.

with job_ads as (

    select *
    from {{ ref('src_job_ads') }}   -- upstream dbt model

)

select

    {{ dbt_utils.generate_surrogate_key(['occupation__label']) }} as occupation_id,
    -- Creates a stable surrogate key from the occupation label.
    -- This key can be used to connect this fact model to an occupation dimension.

    vacancies,              -- number of available positions

    relevance,              -- relevance score from the source data

    application_deadline    -- deadline for applying

from job_ads