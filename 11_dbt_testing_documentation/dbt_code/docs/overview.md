{% docs __overview__ %}

# Job Ads Project

This project turns raw technical-field job advertisements into three dimensions, a
fact-style job-ad table, and a reporting mart. The source models are ephemeral and
prepare fields for the teacher's dimensional-modeling implementation shown below.

> **Note:**  
> Model and column documentation and generic data tests are in `models/schema.yml`.
> The project also keeps its singular relevance test in `tests/check_relevance_value.sql`.

## Dimensional Model

![Dimensional Model](assets/job_ads_dimension_model.png)

{% enddocs %}