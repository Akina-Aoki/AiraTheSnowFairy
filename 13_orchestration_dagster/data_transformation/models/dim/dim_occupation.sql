-- Builds a cleaned occupation dimension from the src_occupation dbt model.
-- src_occupation itself comes from the source table defined in sources.yml,
-- so the data flow is: Snowflake source -> src_occupation -> this model.
--
-- ref('src_occupation') tells dbt that this model depends on src_occupation.
-- dbt_utils.generate_surrogate_key() comes from the dbt_utils package
-- installed with `dbt deps` and creates a stable generated ID.

with src_occupation as (

    select *
    from {{ ref('src_occupation') }}

)

-- Deduplicates occupations so each occupation appears once.
-- max() is used here to pick one value for occupation_group and occupation_field.
select

    {{ dbt_utils.generate_surrogate_key(['occupation']) }} as occupation_id,
    -- Creates a surrogate key from the occupation name.

    occupation,

    max(occupation_group) as occupation_group,

    max(occupation_field) as occupation_field

from src_occupation

group by occupation