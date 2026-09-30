# 3. Ingest JobTech API data with dlt

## What are we doing, and why?

`10_dbt_modeling/dlt_code/load_job_ads.py` is the canonical extraction-and-load script. It makes one HTTP GET request to the JobTech search API, yields each ad to dlt, and replaces a Snowflake landing table. Landing unchanged API data first keeps extraction separate from dbt transformation.

## Configure credentials locally

The code changes into `10_dbt_modeling/dlt_code/`, so a local dlt configuration can live at:

```text
10_dbt_modeling/dlt_code/.dlt/secrets.toml
```

That directory is ignored. Configure the Snowflake destination with account, `EXTRACT_LOADER`, key/password authentication, `DEV_WH`, database `JOB_ADS`, and role `JOB_ADS_DLT_ROLE`. Use dlt's generated Snowflake credential template for your installed version; never copy real values into Markdown or Python. Environment variables are an alternative.

## Read the script from top to bottom

1. `_get_ads()` sends `GET https://jobsearch.api.jobtechdev.se/search`, requests JSON, passes query parameters, fails on HTTP errors, decodes the response, and returns a Python dictionary.
2. `jobads_resource()` is decorated with `@dlt.resource(write_disposition="replace")`. A **resource** describes a stream of loadable records. The response's `hits` value is a list of ad objects; `yield ad` hands one dictionary at a time to dlt without ending the generator.
3. `run_pipeline()` defines pipeline name `jobsearch`, destination `snowflake`, and dataset `staging` (Snowflake schema).
4. The request uses `limit=100` and occupation-field code `6Hq3_tKo_V57`, described in the code as “Yrken med teknisk inriktning.” There is no pagination, so this run requests at most 100 hits.
5. `pipeline.run(..., table_name="technical_field_job_ads")` normalizes JSON. Top-level nested fields become names such as `occupation__label`; dlt may also create child tables for nested arrays/objects.

`replace` means repeated runs replace the resource's destination data rather than append history. The intended main object is:

```text
JOB_ADS.STAGING.TECHNICAL_FIELD_JOB_ADS
```

The database is not hard-coded by `dlt.pipeline`; it comes from destination credentials. Confirm it is `JOB_ADS`.

## Run it

From the repository root:

```bash
source .venv/bin/activate
python 10_dbt_modeling/dlt_code/load_job_ads.py
```

Success prints dlt load information without an exception.

## Exact hand-off to dbt

```text
JobTech /search?limit=100&occupation-field=6Hq3_tKo_V57
  -> 10_dbt_modeling/dlt_code/load_job_ads.py
  -> @dlt.resource yields response["hits"]
  -> dlt pipeline jobsearch, dataset staging, replace
  -> JOB_ADS.STAGING.TECHNICAL_FIELD_JOB_ADS
  -> 10_dbt_modeling/dbt_code/models/src/sources.yml
```

The older `07_extract_load_api_dlt/dlt_code/load_job_ads.py` is a learning version that searches `q=data engineer` and creates `DATA_FIELD_JOB_ADS`. Do not combine that table name with the canonical source. `06_extract_load_csv_dlt/dlt_code/load_csv.py` demonstrates the same resource/pipeline pattern using pandas and `MOVIES.STAGING.NETFLIX`; it is not part of this job-ad pipeline.

## Verify before continuing

```sql
USE ROLE JOB_ADS_DLT_ROLE;
USE WAREHOUSE DEV_WH;
SHOW TABLES IN SCHEMA JOB_ADS.STAGING;
DESC TABLE JOB_ADS.STAGING.TECHNICAL_FIELD_JOB_ADS;
SELECT COUNT(*) FROM JOB_ADS.STAGING.TECHNICAL_FIELD_JOB_ADS;
SELECT OCCUPATION__LABEL, NUMBER_OF_VACANCIES, RELEVANCE,
       APPLICATION_DEADLINE
FROM JOB_ADS.STAGING.TECHNICAL_FIELD_JOB_ADS
LIMIT 10;
```

Confirm the four columns needed by dbt exist. Only then configure dbt's source declaration.
