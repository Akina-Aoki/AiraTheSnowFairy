-- Builds a cleaned employer dimension from the src_employer dbt model.
-- src_employer itself comes from the source table defined in sources.yml,
-- so the data flow is: Snowflake source -> src_employer -> this model.
--
-- ref() is dbt's own function.
-- ref('src_employer') tells dbt that this model depends on src_employer.
-- dbt_utils.generate_surrogate_key() comes from the dbt_utils package
-- installed with `dbt deps` and creates a stable generated ID.


with src_employer as (
    select *
    from {{ ref('src_employer') }}
)

select
-- Creates a surrogate key from the employer name.
    {{ dbt_utils.generate_surrogate_key([
        'employer_workplace',
        'workplace_municipality'
    ])}} as employer_id,
    max(employer_name) as employer_name,
    employer_workplace,
    max(employer_organization_number) as employer_organization_number,
    max(workplace_street_address) as workplace_street_address,
    max(workplace_region) as workplace_region,
    max(workplace_postcode) as workplace_postcode,
    workplace_municipality as workplace_city,
    max(workplace_country) as workplace_country

from src_employer

group by employer_workplace, workplace_municipality

