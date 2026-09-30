# 5. dbt sources and macros

## Source: name an object dbt did not create

File: `10_dbt_modeling/dbt_code/models/src/sources.yml`.

```yaml
sources:
  - name: job_ads
    schema: staging
    tables:
      - name: stg_ads
        identifier: technical_field_job_ads
```

The logical pair `job_ads.stg_ads` resolves to physical table `JOB_ADS.STAGING.TECHNICAL_FIELD_JOB_ADS`. `identifier` is the real table name. No `database:` is declared, so dbt uses the target database from `profiles.yml`; it must be `JOB_ADS`.

Both source models call:

```sql
{{ source('job_ads', 'stg_ads') }}
```

`source()` quotes/resolves the physical relation, records lineage, and lets dbt validate that the named source exists. It does not create or rename `STG_ADS`.

```text
10_dbt_modeling/dlt_code/load_job_ads.py
  -> JOB_ADS.STAGING.TECHNICAL_FIELD_JOB_ADS
  -> sources.yml: source job_ads / table stg_ads / identifier technical_field_job_ads
  -> source('job_ads', 'stg_ads') in src_job_ads.sql and src_occupation.sql
  -> downstream ref() transformations
```

The historical API loader creates `DATA_FIELD_JOB_ADS`; the canonical YAML deliberately points to `TECHNICAL_FIELD_JOB_ADS` instead.

## Project macros

A macro is a reusable Jinja function evaluated while dbt compiles SQL.

### Schema naming override

File: `10_dbt_modeling/dbt_code/macros/generate_schema_name.sql`.

dbt's default behavior normally combines target schema and custom schema (for example target `WAREHOUSE` plus `+schema: warehouse` can become `WAREHOUSE_WAREHOUSE`). This override returns the trimmed custom name directly. Thus the configured outputs are exactly `WAREHOUSE` and `MARTS`; nodes without a custom schema use `target.schema`.

dbt invokes the specially named macro automatically. Without it, the grants on `JOB_ADS.WAREHOUSE`/`MARTS` might not match the generated schema names. The simplified override is convenient for this learning project but can make developer environments write to the same schemas; production teams often retain target-prefix isolation.

### `dbt_utils.generate_surrogate_key`

Declared dependency: `10_dbt_modeling/dbt_code/packages.yml`; called in:

- `models/fct/fct_job_ads.sql` with `occupation__label`;
- `models/dim/dim_occupation.sql` with `occupation`.

It deterministically hashes the natural occupation value into `occupation_id`, allowing the fact and dimension to join. Without `dbt deps`, compilation reports an undefined `dbt_utils` macro. Both inputs originate from the same source label, which is why keys match.

### Unused local helper macros

- `10_dbt_modeling/dbt_code/macros/string_utils.sql` defines `capitalize_first_letter(column)`, producing null or title-like first-letter capitalization.
- `10_dbt_modeling/dbt_code/macros/translate_headline.sql` maps exact `Data engineer` to `Junior data engineer`.

Neither macro is called by any canonical model. They are learning helpers carried forward from `09_setup_dbt/`; removing them would not change the current DAG. In that older project, `translate_headline` is called by `models/refined/updated_headline_macro.sql`, but the canonical job-ad model does not include that refined layer.

## Verify before continuing

From `10_dbt_modeling/dbt_code/`:

```bash
dbt deps
dbt parse
dbt show --select src_job_ads --limit 5
```

Because `src_job_ads` is ephemeral, `dbt show` is the useful preview. If Snowflake reports a missing relation, compare the dlt table, YAML `identifier`, profile database, and source schema exactly.
