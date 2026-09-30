# 10. Beginner troubleshooting

Start at the first failing layer: identity/grants → dlt table → dbt source → models/tests → dashboard.

## Snowflake authentication and authorization

### “Insufficient privileges” or object appears missing

Run:

```sql
SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_SECONDARY_ROLES(),
       CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();
SHOW GRANTS TO ROLE JOB_ADS_DLT_ROLE;
```

A role needs `USAGE` on `DEV_WH`, `JOB_ADS`, and the schema **plus** the object action. dlt also needs `CREATE TABLE` on staging. dbt needs creation privileges on warehouse/marts. Reporter needs only `SELECT` on marts objects. Ensure the role was granted to the user; setting `DEFAULT_ROLE` is not itself a grant.

### Service user versus human user

`EXTRACT_LOADER` and `TRANSFORMER` are automation identities; your own login is human. Do not put your personal broad role into pipeline credentials. `REPORTER` has conflicting password-user and key-based service-user examples; choose one. The checked-in connector currently expects a password.

### Existing versus future objects

Future grants do not retroactively fix existing objects; all-object grants do not automatically cover later ones. The repository grants both in relevant schemas. Re-check object ownership if dbt-created relations still lack reporter access.

## dlt ingestion

### Source table does not exist

Run the canonical `10_dbt_modeling/dlt_code/load_job_ads.py`, not the older loader. Confirm credentials point at database `JOB_ADS`; code only specifies dataset/schema `STAGING`. The canonical table is `TECHNICAL_FIELD_JOB_ADS`, whereas the learning version creates `DATA_FIELD_JOB_ADS`.

### API/network or empty load

The script calls `raise_for_status()`, so HTTP errors stop it. Check connectivity and print/load information. It requests only one page with limit 100 and a fixed occupation-field code; zero rows may mean no current matches or an upstream API/code change.

### Credentials are not found

The script changes directory to `10_dbt_modeling/dlt_code`, so place local `.dlt` configuration there or use correctly named environment variables. Do not commit it.

## dbt configuration

### `dbt debug` cannot find a profile

Canonical `dbt_project.yml` says `profile: dbt_code`; the top-level key in `~/.dbt/profiles.yml` must be exactly `dbt_code`. The older README's `dbt_snowflake` name is historical unless both files are changed together. Run dbt from `10_dbt_modeling/dbt_code/`.

### Connection fails although YAML parses

Verify account identifier, user authentication method, role assignment, warehouse/database names, and private-key/password fields. A successful `dbt debug` proves connectivity and configuration, but not source-table existence.

### Schema becomes `WAREHOUSE_WAREHOUSE`

Confirm `macros/generate_schema_name.sql` exists and parses. Default dbt schema generation concatenates target and custom schema; the canonical override returns exactly the custom schema. Also confirm you are executing the canonical project rather than another numbered copy.

### Undefined `dbt_utils` or `dbt_expectations`

Run `dbt deps` in the same project directory. `dbt_packages/` is intentionally not cloned. `dbt_expectations` exists only in the later testing snapshot unless you add it to canonical `packages.yml`; also check old package compatibility with your installed dbt version.

## Sources, refs, and models

### Source is missing

Trace all four names: profile database `JOB_ADS`; YAML schema `STAGING`; YAML source/table logical names `job_ads`/`stg_ads`; identifier `TECHNICAL_FIELD_JOB_ADS`. `source()` must use the logical names, while Snowflake must contain the identifier.

### `ref()` cannot resolve a model

`ref()` uses the SQL filename/model name without `.sql`. The actual names are `src_job_ads`, `src_occupation`, `fct_job_ads`, `dim_occupation`, and `mart_technical_jobs`. A typo is a compile error. Run `dbt parse` before `dbt run`.

### Expected source tables are absent after `dbt run`

`src_job_ads` and `src_occupation` are intentionally ephemeral. They compile as CTEs and create no physical objects. Fact/dimension/mart models materialize as tables.

### Relationship test refers to a model that does not exist

The actual test correctly uses `ref('dim_occupation')`. If renamed, update the ref. A nonexistent ref creates a parsing/compilation ERROR, not a data FAIL.

### A test warns or fails

Read the named assertion. The vacancy maximum uses warning severity; other configured expectations normally error. Inspect offending data before changing bounds. The suite has no current `not_null`, `unique`, or `accepted_values` tests, so do not expect them in output.

## Streamlit

### Running `python dashboard.py` does not produce a normal app

Use:

```bash
cd 12_dashboard_streamlit
streamlit run dashboard.py
```

`python run_dashboard.py` is also provided as a wrapper. Test the connection independently with `python connect_data_warehouse.py`.

### Table/column errors

The default query relies on connection context `JOB_ADS.MARTS` and table `MART_TECHNICAL_JOBS`. Confirm `.env` names and reporter grants. The dashboard expects uppercase `VACANCIES` and `OCCUPATION_GROUP` DataFrame columns.

## Secret accidentally committed

Remove the value from the working tree, rotate/revoke it in Snowflake, then purge Git history if it was pushed. Merely adding it to `.gitignore` does not remove history. The literal password in `12_dashboard_streamlit/streamlit_sql/01_setup_user_reporter.sql` should be considered exposed and must not be reused.

## Final diagnostic commands

```bash
git status --short
cd 10_dbt_modeling/dbt_code
dbt debug
dbt deps
dbt parse
dbt run
dbt test
```

If those pass, return to `12_dashboard_streamlit/`, test the connector, and start Streamlit.
