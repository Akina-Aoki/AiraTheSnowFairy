# 4. Initialize and configure dbt

## Initialize from scratch

**dbt** compiles model SELECT statements and runs them in Snowflake. From `10_dbt_modeling/`, a new builder would run:

```bash
cd 10_dbt_modeling
dbt init dbt_code
cd dbt_code
```

`dbt init` creates `dbt_code/` with `dbt_project.yml`, models and supporting directories, and normally guides creation of `~/.dbt/profiles.yml`. This repository already contains the resulting project, so do **not** run init over it when following the existing checkout; simply `cd 10_dbt_modeling/dbt_code`.

## Configure `profiles.yml` outside Git

The actual profile is intentionally absent. Create `~/.dbt/profiles.yml` with profile key `dbt_code`, because canonical `10_dbt_modeling/dbt_code/dbt_project.yml` says `profile: 'dbt_code'`:

```yaml
dbt_code:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <ACCOUNT_IDENTIFIER>
      user: transformer
      password: <LOCAL_SECRET>
      role: job_ads_dbt_role
      database: job_ads
      warehouse: dev_wh
      schema: staging
      threads: 4
      client_session_keep_alive: false
```

For the repository's service-user design, prefer key-pair fields supported by your dbt-snowflake version instead of a password. The public key belongs on `TRANSFORMER`; the private key and any passphrase stay local. `target: dev` selects the `dev` output. The `schema: staging` value is dbt's default schema, not permission to access it.

The `09_setup_dbt/README.md` learning example calls its profile `dbt_snowflake`, while the final `dbt_project.yml` expects `dbt_code`. This is a real inconsistency: the top-level profile key and project `profile` value must match exactly.

## Understand `dbt_project.yml`

File: `10_dbt_modeling/dbt_code/dbt_project.yml`.

| Setting | Meaning here |
|---|---|
| `name: dbt_code` | project/package namespace used below `models:` |
| `version: 1.0.0` | project metadata, not the installed dbt version |
| `profile: dbt_code` | looks up the same key in `profiles.yml` |
| `model-paths: [models]` | model SQL lives under `models/` |
| analysis/test/seed/macro/snapshot paths | tell dbt where each resource type lives |
| `clean-targets` | `dbt clean` removes `target/` and `dbt_packages/` |
| `+materialized: table` | default model output is a physical table |
| `src: +materialized: ephemeral` | source-cleaning models compile into downstream SQL and create no relation |
| `src: +schema: staging` | logical custom schema; irrelevant to relation creation while ephemeral |
| `dim`, `fct`: `+schema: warehouse` | fact/dimension tables are created in `JOB_ADS.WAREHOUSE` |
| `mart: +schema: marts` | final mart table is created in `JOB_ADS.MARTS` |

Directory names under `models/` match the keys `src`, `dim`, `fct`, and `mart`; folder-level settings cascade to files inside them.

## Install packages

`10_dbt_modeling/dbt_code/packages.yml` requests `dbt-labs/dbt_utils` version `1.3.0`. It supplies `generate_surrogate_key`, used by both fact and dimension models. `package-lock.yml` records the resolved package/version and hash.

```bash
cd 10_dbt_modeling/dbt_code
dbt deps
```

This downloads code to ignored `dbt_packages/`. Run it after a fresh clone and whenever `packages.yml` or its lock changes. Do not commit that generated directory.

## Connection and execution sequence

```bash
cd 10_dbt_modeling/dbt_code
dbt debug
dbt deps
dbt run
dbt run --select mart_technical_jobs
dbt show --select mart_technical_jobs
dbt test
dbt docs generate
dbt docs serve
```

- `dbt debug`: validates project/profile files, adapter, authentication, and connection. “All checks passed” means connectivity works, not that source data exists.
- `dbt deps`: installs packages.
- `dbt run`: compiles and creates all models in DAG order.
- `dbt run --select mart_technical_jobs`: selects one model only; use `+mart_technical_jobs` to include upstream dependencies.
- `dbt show --select ...`: compiles/executes a preview query without building a new model relation.
- `dbt test`: runs declared data tests (after adopting the test configuration in chapter 7).
- `dbt docs generate`: writes catalog/manifest artifacts under `target/`.
- `dbt docs serve`: starts a local documentation site and keeps the terminal occupied.

Success summaries show `PASS`/`OK` and zero errors. `target/`, `logs/`, and `dbt_packages/` are reproducible/generated and ignored.

## Verify before continuing

```bash
dbt --version
dbt debug
dbt deps
```

Confirm the active output reports role `JOB_ADS_DBT_ROLE`, database `JOB_ADS`, warehouse `DEV_WH`, and a successful connection before building models.
