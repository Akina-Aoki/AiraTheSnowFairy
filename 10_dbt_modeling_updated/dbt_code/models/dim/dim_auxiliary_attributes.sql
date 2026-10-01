with src_auxiliary_attributes as (
    select *
    from {{ ref('src_auxiliary_attributes') }}
)

select distinct
    {{ dbt_utils.generate_surrogate_key(['job_ads_id']) }} as  auxiliary_attributes_id,
    experience_required,
    driver_license,
    access_to_own_car
from src_auxiliary_attributes