# 9. Full rebuild checklist

Use this after reading chapters 1–8; it is intentionally concise.

## A. Repository and local tools

- [ ] Create/clone the Git repository.
- [ ] Create and activate `.venv` (or uv environment).
- [ ] Install dlt Snowflake support, requests, pandas, dbt Core/Snowflake, dotenv, connector, and Streamlit.
- [ ] Preserve ignore rules for `.env`, `.dlt/`, keys, `profiles.yml`, `.venv/`, `target/`, `logs/`, and `dbt_packages/`.
- [ ] Replace/rotate the literal reporter password from the learning SQL; never reuse it.

## B. Snowflake foundation

- [ ] Create `DEV_WH` using the relevant statement in `05_users_and_roles/01_setup_dwh.sql`.
- [ ] Run `07_extract_load_api_dlt/sql/01_setup_database.sql` for `JOB_ADS.STAGING`.
- [ ] Run/adapt `07_extract_load_api_dlt/sql/setup_service_acc.sql` to create `EXTRACT_LOADER`, `JOB_ADS_DLT_ROLE`, assignments, and staging grants.
- [ ] Create `JOB_ADS_DBT_ROLE`, then create `TRANSFORMER` from the placeholder template `09_setup_dbt/sql/setup_service_acc.sql`, then complete grants in `10_dbt_modeling/sql/00_grant_user.sql`.
- [ ] Run canonical scripts `02_setup_warehouse.sql`, `03_setup_wh_grants.sql`, `04_setup_marts.sql`, and `05_setup_marts_grants.sql` in that order.
- [ ] Verify every user's role assignment and every role's warehouse/database/schema/object grants.

## C. Ingest

- [ ] Configure local dlt Snowflake credentials for `EXTRACT_LOADER`, `JOB_ADS_DLT_ROLE`, `DEV_WH`, and `JOB_ADS`.
- [ ] Run `python 10_dbt_modeling/dlt_code/load_job_ads.py`.
- [ ] Verify rows/columns in `JOB_ADS.STAGING.TECHNICAL_FIELD_JOB_ADS`.

## D. Transform

- [ ] If building rather than copying, run `dbt init dbt_code` from `10_dbt_modeling/`.
- [ ] Create `~/.dbt/profiles.yml`; match profile name `dbt_code` and target the transformer role, `JOB_ADS`, `DEV_WH`, and default schema `STAGING`.
- [ ] From `10_dbt_modeling/dbt_code/`, run `dbt debug` and require all checks to pass.
- [ ] Run `dbt deps` to install pinned `dbt_utils`.
- [ ] Confirm `sources.yml` maps `stg_ads` to `TECHNICAL_FIELD_JOB_ADS`.
- [ ] Run `dbt run` (or `dbt build` once tests are integrated).
- [ ] Verify `WAREHOUSE.FCT_JOB_ADS`, `WAREHOUSE.DIM_OCCUPATION`, and `MARTS.MART_TECHNICAL_JOBS`.
- [ ] Preview with `dbt show --select mart_technical_jobs`.

## E. Test and document

- [ ] Add `11_dbt_testing/dbt_code/models/schema.yml` and `dbt_expectations` package entry to the canonical project if maintaining one end-to-end project.
- [ ] Run `dbt deps`, then `dbt test`; investigate FAIL/ERROR and review WARN.
- [ ] Run `dbt docs generate`, optionally `dbt docs serve`, and inspect lineage.

## F. Report

- [ ] Choose password or key-pair reporter authentication; make it consistent with Python.
- [ ] Create/grant `JOB_ADS_REPORTER_ROLE` using `12_dashboard_streamlit/streamlit_sql/`.
- [ ] Create ignored `12_dashboard_streamlit/.env` with reporter connection values.
- [ ] Run `python connect_data_warehouse.py` from that folder.
- [ ] Run `streamlit run dashboard.py` and verify the metrics/table.

## One-line dependency audit

```text
DEV_WH + JOB_ADS/STAGING + dlt grants
  -> dlt load
  -> physical source table
  -> dbt profile/source/packages/macros
  -> ephemeral source models
  -> warehouse fact/dimension
  -> tested mart
  -> reporter SELECT privilege
  -> pandas DataFrame
  -> Streamlit dashboard
```

Never continue past a failed verification: downstream errors often only hide an upstream missing object or grant.
