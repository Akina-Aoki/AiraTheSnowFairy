-- Builds a mart/reporting model by combining the job ads fact table
-- with the occupation dimension table.
--
-- Data flow:
-- Snowflake source -> source models -> fact/dimension models -> this mart model.
--
-- ref('fct_job_ads') tells dbt to use the fact model.
-- ref('dim_occupation') tells dbt to use the occupation dimension model.
-- dbt also uses these ref() calls to understand the dependency order.

with
    fct_job_ads as (

        select *
        from {{ ref('fct_job_ads') }}

    ),

    dim_occupation as (

        select *
        from {{ ref('dim_occupation') }}

    )

select

    f.vacancies,                -- number of vacancies from the fact table

    f.relevance,                -- relevance score from the fact table

    o.occupation,               -- occupation name from the dimension table

    o.occupation_group,         -- occupation group

    o.occupation_field,         -- broader occupation field

    f.application_deadline      -- application deadline from the fact table

from fct_job_ads f

left join dim_occupation o
    on f.occupation_id = o.occupation_id
    -- Connects the fact and dimension tables using the shared surrogate key.

where o.occupation_field = 'Yrken med teknisk inriktning'
-- Keeps only job ads that belong to the technical occupation field.