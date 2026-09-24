# dbt Macros — Beginner Guide

This guide explains **what dbt macros do**, **which files connect to each other**, and **where to look when something breaks**.

---

# 1. Big picture: how the whole project connects

Your project has two main parts:

```text
09_lecture_dbt/
│
├── dlt_code/
│   ├── .dlt/
│   │   └── secrets.toml
│   └── load_job_ads.py
│
└── dbt_code/
    ├── dbt_project.yml
    ├── models/
    │   ├── staging/
    │   │   └── original_headline.sql
    │   └── refined/
    │       ├── updated_headline.sql
    │       └── updated_headline_macro.sql
    │
    └── macros/
        ├── translate_headline.sql
        ├── string_utils.sql
        └── generate_schema_name.sql
```

The full flow is:

```text
JobTech API
    ↓
dlt_code/load_job_ads.py
    ↓
Snowflake raw table
JOB_ADS.STAGING.DATA_FIELD_JOB_ADS
    ↓
dbt model: original_headline.sql
    ↓
dbt model: updated_headline.sql
    ↓
dbt model: updated_headline_macro.sql
```

Macros are used **inside the dbt part**.

---

# 2. Files to check, in order

If you want to understand how everything connects, check the files in this order.

## File 1 — `dlt_code/load_job_ads.py`

This file gets the raw data from the API and loads it into Snowflake.

Important line:

```python
run_pipeline(table_name="data_field_job_ads")
```

That means dlt loads into:

```text
JOB_ADS.STAGING.DATA_FIELD_JOB_ADS
```

So if your dbt model expects `data_field_job_ads`, this is the file that must create/populate it.

---

## File 2 — `dlt_code/.dlt/secrets.toml`

This file tells dlt how to connect to Snowflake.

Example:

```toml
[destination.snowflake.credentials]

database = "job_ads"
username = "extract_loader"
password = "..."
host = "..."
warehouse = "dev_wh"
role = "job_ads_dlt_role"
```

This controls:

```text
Which Snowflake account?
Which database?
Which warehouse?
Which user?
Which role?
```

If dlt cannot connect, check this file.

---

## File 3 — `dbt_code/dbt_project.yml`

This file tells dbt how the dbt project is structured.

Example:

```yaml
models:
  dbt_code:

    staging:
      +schema: staging
      +materialized: table

    refined:
      +schema: warehouse
      +materialized: view
```

This means:

```text
models/staging/
    ↓
Snowflake schema: STAGING
materialized as TABLE

models/refined/
    ↓
Snowflake schema: WAREHOUSE
materialized as VIEW
```

So if dbt is putting models in the wrong schema, check:

```text
dbt_project.yml
```

---

## File 4 — `~/.dbt/profiles.yml`

This file is outside your project folder.

It tells dbt how to connect to Snowflake.

Your connection uses values like:

```text
database: job_ads
warehouse: dev_wh
role: job_ads_dbt_role
schema: warehouse
user: transformer
```

So:

```text
dbt_project.yml
```

controls the dbt project behavior,

while:

```text
profiles.yml
```

controls the Snowflake connection.

If `dbt debug` fails, check `profiles.yml`.

---

# 3. How the dbt models connect

Now we move into the actual dbt model flow.

---

## `original_headline.sql`

This is your first dbt model.

```sql
SELECT
    headline

FROM job_ads.staging.data_field_job_ads
```

It reads directly from the raw Snowflake table:

```text
JOB_ADS.STAGING.DATA_FIELD_JOB_ADS
```

and creates:

```text
JOB_ADS.STAGING.ORIGINAL_HEADLINE
```

because the file is inside:

```text
models/staging/
```

Flow:

```text
DATA_FIELD_JOB_ADS
        ↓
original_headline.sql
        ↓
STAGING.ORIGINAL_HEADLINE
```

---

# 4. How `ref()` connects dbt models

Inside your other models you use:

```sql
{{ ref('original_headline') }}
```

`ref()` means:

> Use the dbt model called `original_headline`.

So dbt knows:

```text
updated_headline
depends on
original_headline
```

Example:

```sql
WITH staging_data AS (

    SELECT *
    FROM {{ ref('original_headline') }}

)
```

dbt automatically finds the correct Snowflake object.

You do not need to write:

```sql
FROM job_ads.staging.original_headline
```

because `ref()` handles that connection.

---

# 5. `updated_headline.sql`

This model uses:

```sql
{{ ref('original_headline') }}
```

So its input is:

```text
STAGING.ORIGINAL_HEADLINE
```

Then it applies a normal SQL `CASE`:

```sql
CASE
    WHEN headline = 'Data engineer'
    THEN 'Junior data engineer'

    ELSE headline
END AS job_title
```

So the flow is:

```text
STAGING.ORIGINAL_HEADLINE
        ↓
ref('original_headline')
        ↓
CASE transformation
        ↓
WAREHOUSE.UPDATED_HEADLINE
```

This model does **not** use your custom macro.

---

# 6. `updated_headline_macro.sql`

This model also starts with:

```sql
{{ ref('original_headline') }}
```

But instead of writing the `CASE` logic directly, it calls:

```sql
{{ translate_headline('headline') }}
```

This tells dbt:

> Find the macro called `translate_headline` and insert its SQL logic here.

Flow:

```text
STAGING.ORIGINAL_HEADLINE
        ↓
updated_headline_macro.sql
        ↓
calls translate_headline()
        ↓
macros/translate_headline.sql
        ↓
WAREHOUSE.UPDATED_HEADLINE_MACRO
```

---

# 7. `macros/translate_headline.sql`

This is the macro used by:

```text
updated_headline_macro.sql
```

Example:

```sql
{% macro translate_headline(column) %}

    CASE
        WHEN {{ column }} = 'Data engineer'
        THEN 'Junior data engineer'

        ELSE {{ column }}
    END

{% endmacro %}
```

The connection is:

```text
updated_headline_macro.sql
        ↓
{{ translate_headline('headline') }}
        ↓
macros/translate_headline.sql
```

Important:

The filename can technically be different, but the macro name must match:

```sql
{% macro translate_headline(column) %}
```

and:

```sql
{{ translate_headline('headline') }}
```

These names must match exactly.

If dbt says:

```text
'translate_headline' is undefined
```

check:

```text
macros/translate_headline.sql
```

---

# 8. `macros/string_utils.sql`

This file contains:

```sql
{% macro capitalize_first_letter(column) %}
```

It is a different macro.

Example use:

```sql
{{ capitalize_first_letter('headline') }}
```

If no model calls it, it does nothing during your current transformation.

It simply stays available for future models.

Connection:

```text
model.sql
    ↓
{{ capitalize_first_letter(...) }}
    ↓
macros/string_utils.sql
```

---

# 9. `macros/generate_schema_name.sql`

This macro affects **where dbt creates models**.

Without it, dbt can combine:

```text
default schema from profiles.yml
+
custom schema from dbt_project.yml
```

and produce:

```text
WAREHOUSE_STAGING
WAREHOUSE_WAREHOUSE
```

Your custom macro changes that behavior.

With it:

```yaml
+schema: staging
```

becomes:

```text
STAGING
```

and:

```yaml
+schema: warehouse
```

becomes:

```text
WAREHOUSE
```

So this macro connects to:

```text
profiles.yml
        +
dbt_project.yml
        ↓
generate_schema_name.sql
        ↓
final Snowflake schema name
```

It does not transform your job-title data.

It changes dbt's schema naming behavior.

---

# 10. The full connection map

This is the most important diagram.

```text
                    API
                     │
                     ▼
          dlt_code/load_job_ads.py
                     │
                     ▼
     JOB_ADS.STAGING.DATA_FIELD_JOB_ADS
                     │
                     ▼
       models/staging/original_headline.sql
                     │
                     ▼
       STAGING.ORIGINAL_HEADLINE
               │              │
               │              │
               ▼              ▼
 updated_headline.sql   updated_headline_macro.sql
               │              │
               │              ▼
               │      translate_headline()
               │              │
               │              ▼
               │   macros/translate_headline.sql
               │              │
               ▼              ▼
WAREHOUSE.UPDATED_HEADLINE   WAREHOUSE.UPDATED_HEADLINE_MACRO
```

And separately:

```text
profiles.yml
     +
dbt_project.yml
     ↓
generate_schema_name.sql
     ↓
Controls schema names:
STAGING / WAREHOUSE
```

---

# 11. `ref()` vs macro vs source table

These three things are easy to mix up.

## Direct Snowflake table

```sql
FROM job_ads.staging.data_field_job_ads
```

Means:

> Read directly from a real Snowflake table.

---

## `ref()`

```sql
{{ ref('original_headline') }}
```

Means:

> Read from another dbt model.

Think:

```text
MODEL → MODEL
```

---

## Macro

```sql
{{ translate_headline('headline') }}
```

Means:

> Insert reusable SQL logic here.

Think:

```text
MODEL → SQL LOGIC
```

---

# 12. What happens when you run `dbt run`

When you run:

```bash
dbt run
```

dbt roughly does this:

```text
1. Read profiles.yml
   ↓
Connect to Snowflake

2. Read dbt_project.yml
   ↓
Understand model folders and schemas

3. Read models/
   ↓
Find SQL models

4. Read macros/
   ↓
Find reusable Jinja/SQL logic

5. Resolve ref()
   ↓
Work out model dependencies

6. Resolve macro calls
   ↓
Insert macro SQL into models

7. Compile everything into normal SQL
   ↓
Send SQL to Snowflake

8. Snowflake creates tables/views
```

---

# 13. Where should I look when something breaks?

Use this checklist.

| Problem | File/place to check |
|---|---|
| API data is missing | `dlt_code/load_job_ads.py` |
| dlt cannot connect to Snowflake | `.dlt/secrets.toml` |
| Raw Snowflake table has 0 rows | dlt pipeline / API query |
| `dbt debug` fails | `~/.dbt/profiles.yml` |
| dbt creates models in wrong schema | `dbt_project.yml` + `generate_schema_name.sql` |
| dbt says model not found | Check `ref()` and model filename |
| dbt says macro is undefined | Check `macros/` and macro name |
| Transformation result is wrong | Check model SQL or transformation macro |
| `original_headline` is empty | Check `DATA_FIELD_JOB_ADS` first |
| Downstream models are empty | Check the upstream model first |

---

# 14. Debug from upstream to downstream

Always debug in this order:

```text
1. Did API return data?
        ↓
2. Did dlt load it?
        ↓
3. Does the raw Snowflake table have rows?
        ↓
4. Does the first dbt staging model have rows?
        ↓
5. Do refined models have rows?
        ↓
6. Are macros producing the expected transformation?
```

For this project:

```text
DATA_FIELD_JOB_ADS
        ↓
ORIGINAL_HEADLINE
        ↓
UPDATED_HEADLINE
        ↓
UPDATED_HEADLINE_MACRO
```

If `DATA_FIELD_JOB_ADS` has 0 rows, everything below it will also have 0 rows.

---

# 15. The easiest mental model

Think of each file as having one job:

```text
load_job_ads.py
= Get data into Snowflake

secrets.toml
= Tell dlt how to connect

profiles.yml
= Tell dbt how to connect

dbt_project.yml
= Tell dbt how the project should behave

original_headline.sql
= First transformation model

ref()
= Connect one dbt model to another

translate_headline.sql
= Reusable transformation logic

string_utils.sql
= Extra reusable text logic

generate_schema_name.sql
= Control dbt schema naming
```

---

# Final takeaway

The most important thing is to follow the dependency chain.

For this project:

```text
API
↓
dlt
↓
Snowflake raw table
↓
dbt staging model
↓
ref()
↓
dbt refined model
↓
macro
↓
final transformed result
```

When something fails, do not check every file at once.

Start from the top of the chain and move downward until you find the first place where the data or configuration is wrong.
