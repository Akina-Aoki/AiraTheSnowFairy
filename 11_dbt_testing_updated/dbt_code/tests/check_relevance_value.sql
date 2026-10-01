select *
from {{ ref('fct_job_ads') }}
where relevance < 0 or relevance > 1