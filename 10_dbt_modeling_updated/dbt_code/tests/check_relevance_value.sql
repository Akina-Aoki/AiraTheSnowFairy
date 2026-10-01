select *
from {{ ref('fct_job_ads') }}
where relevance > 1