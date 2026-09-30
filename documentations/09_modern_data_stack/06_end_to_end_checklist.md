# 06 — End-to-End Checklist: Blank Repo to dbt-Ready Warehouse

Use this when you remember the tools but forget the order.

---

# Phase 0 — Blank Git repository

```text
[ ] Open repo in VS Code
[ ] Create .gitignore
[ ] Create sql/
[ ] Create dlt_code/
[ ] Create modeling/
[ ] Check git status
```

Do this before creating secrets.

---

# Phase 1 — Snowflake foundation

Use `SYSADMIN`:

```text
[ ] dev_wh
[ ] PROJECT_DB
[ ] PROJECT_DB.staging
```

Use `USERADMIN`:

```text
[ ] project_dlt_role
[ ] extract_loader
```

Use `SECURITYADMIN`:

```text
[ ] project_dlt_role -> extract_loader
[ ] warehouse USAGE
[ ] database USAGE
[ ] staging schema USAGE
[ ] CREATE TABLE on staging
[ ] SELECT / INSERT / UPDATE / DELETE on staging tables
[ ] future-table grants
```

Verify:

```sql
SHOW GRANTS TO ROLE project_dlt_role;
SHOW GRANTS TO USER extract_loader;
```

---

# Phase 2 — Local Python environment

```bash
pip install uv
uv venv
```

Windows Git Bash:

```bash
source .venv/Scripts/activate
```

Install ingestion tools:

```bash
uv pip install "dlt[snowflake]" pandas requests ipykernel "dlt[parquet]"
```

---

# Phase 3 — Configure dlt

Create:

```text
dlt_code/.dlt/secrets.toml
```

```toml
[destination.snowflake.credentials]
database = "PROJECT_DB"
username = "extract_loader"
password = "<PASSWORD>"
host = "<ACCOUNT_IDENTIFIER>"
warehouse = "dev_wh"
role = "project_dlt_role"
```

Verify `.gitignore` protects it.

---

# Phase 4 — Choose ingestion route

## Route A — CSV

```text
[ ] Put CSV in dlt_code/data/
[ ] Read with pandas
[ ] Wrap in @dlt.resource
[ ] Create dlt.pipeline(...)
[ ] pipeline.run(...)
[ ] Load to staging
```

Follow `02_dlt_csv_ingestion.md`.

## Route B — API

```text
[ ] Explore API
[ ] Understand JSON
[ ] Identify records list
[ ] Check pagination
[ ] Protect API key
[ ] Create requests helper
[ ] Wrap records in @dlt.resource
[ ] Create dlt.pipeline(...)
[ ] pipeline.run(...)
[ ] Load to staging
```

Follow `03_dlt_api_ingestion.md`.

---

# Phase 5 — Validate ingestion

```sql
USE WAREHOUSE dev_wh;
USE DATABASE PROJECT_DB;
USE SCHEMA staging;

SHOW TABLES;
```

Then:

```sql
SELECT COUNT(*)
FROM <YOUR_TABLE>;
```

And:

```sql
SELECT *
FROM <YOUR_TABLE>
LIMIT 10;
```

Do not move on until the staging data is actually there.

---

# Phase 6 — Design the dimensional model

```text
[ ] Define business process
[ ] Declare grain
[ ] Identify fact table
[ ] Identify dimensions
[ ] Identify measures
[ ] Decide keys
[ ] Draw relationships
[ ] Save DBML model
```

Follow `04_dimensional_modeling.md`.

---

# Phase 7 — Snowflake setup for dbt

Create:

```text
[ ] project_dbt_role
[ ] transformer user
[ ] PROJECT_DB.warehouse
[ ] PROJECT_DB.marts
```

Grant:

```text
[ ] project_dlt_role -> project_dbt_role
[ ] dbt CREATE TABLE/VIEW on warehouse
[ ] dbt DML/SELECT on warehouse
[ ] dbt CREATE TABLE/VIEW on marts
[ ] dbt DML/SELECT on marts
[ ] project_dbt_role -> transformer
```

Test permissions manually in Snowflake.

---

# Phase 8 — Install and initialize dbt

```bash
uv pip install dbt-core dbt-snowflake
```

Only if you do not already have a dbt project:

```bash
dbt init dbt_code
```

Remember:

```text
dbt init once per dbt project
```

---

# Phase 9 — Configure dbt

Configure:

```text
~/.dbt/profiles.yml
```

Then:

```text
dbt_code/dbt_project.yml
```

Add when needed:

```text
dbt_code/packages.yml
dbt_code/macros/generate_schema_name.sql
```

Test:

```bash
cd dbt_code
dbt debug
```

---

# Phase 10 — Ready for transformation

```text
SOURCE
  |
  v
dlt
  |
  v
PROJECT_DB.staging
  |
  v
dbt
  |
  +--> PROJECT_DB.warehouse
  |       +--> dim_...
  |       +--> fct_...
  |
  +--> PROJECT_DB.marts
          +--> mart_...
```

Useful checks:

```bash
dbt parse
dbt show --select <model> --limit 20
dbt run --select <model>
dbt test
```

---

# What should be in Git?

## Commit

```text
README/documentation
safe SQL setup files
Python ingestion code
DBML data model
dbt project
dbt models
macros
tests
.gitignore
```

## Never commit

```text
Snowflake passwords
API keys
.dlt/secrets.toml
.env files containing secrets
SQL files containing passwords
```

## Usually ignore because generated

```text
.venv/
dbt_code/target/
dbt_code/logs/
dbt_code/dbt_packages/
__pycache__/
```

---

# Fast recovery checklist

If something breaks, check in this order:

```text
1. Am I in the correct folder?
2. Is the correct .venv activated?
3. Can I connect to Snowflake?
4. Am I using the correct Snowflake role?
5. Does that role have the required grants?
6. Is the database/schema name correct?
7. Can dlt find .dlt/secrets.toml?
8. Is the source returning data?
9. Did dlt actually load a table?
10. Does dbt debug pass?
11. Does dbt parse pass?
12. Can dbt show the model?
13. Can dbt run the model?
```

This order prevents debugging the transformation layer when the real problem is authentication, permissions, source data, or environment setup.
