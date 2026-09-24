# Modern Data Stack Setup Playbook

A reusable, step-by-step guide for starting a data engineering project from a **blank GitHub repository in VS Code**.

This playbook follows the same learning flow as the course repository:

- `05_users_and_roles`
- `06_extract_load_csv_dlt`
- `07_extract_load_api_dlt`
- `08_dimensional_modeling`
- `09_setup_dbt`

Course reference: https://github.com/AIgineerAB/modern-data-stack-course

---

## 1. The architecture you are building

```text
CSV / API
    |
    v
   dlt
    |
    v
Snowflake
+------------------+
| staging          |  <- raw/landing data
+------------------+
        |
        v
       dbt
        |
        v
+------------------+
| warehouse        |  <- dimensions + facts
+------------------+
        |
        v
+------------------+
| marts            |  <- business-facing models
+------------------+
        |
        v
BI / dashboard / analysis
```

The main idea is:

1. **Snowflake** provides the warehouse, database, schemas, users, roles, and privileges.
2. **dlt** extracts data from a source and loads it into the `staging` schema.
3. **Dimensional modeling** defines how the transformed data should be structured.
4. **dbt** transforms staging data into warehouse and mart models.

---

## 2. Which guide should I follow?

| Situation | Guide |
|---|---|
| I have a completely blank repo | Start here, then read `01_snowflake_foundation.md` |
| My source is a CSV | `02_dlt_csv_ingestion.md` |
| My source is an API | `03_dlt_api_ingestion.md` |
| I need to design fact and dimension tables | `04_dimensional_modeling.md` |
| I am ready to transform the staging data | `05_dbt_setup.md` |
| I forgot the full order | `06_end_to_end_checklist.md` |

---

## 3. Recommended project structure

You do **not** need every folder on day one. Create them as the project grows.

```text
my-data-project/
│
├── README.md
├── .gitignore
│
├── sql/
│   ├── 00_setup_warehouse_database.sql
│   ├── 01_setup_roles.sql
│   ├── 02_setup_dlt_user.sql        # contains password -> gitignored
│   └── 03_check_grants.sql
│
├── dlt_code/
│   ├── .dlt/
│   │   └── secrets.toml             # NEVER commit
│   ├── data/                         # useful for CSV projects
│   ├── load_csv.py                   # Scenario A
│   └── load_api.py                   # Scenario B
│
├── modeling/
│   └── dimensional_model.dbml
│
└── dbt_code/
    ├── dbt_project.yml
    ├── models/
    ├── macros/
    ├── seeds/
    ├── snapshots/
    └── tests/
```

---

## 4. Naming template

For a new project, decide these names first.

| Object | Example |
|---|---|
| Snowflake warehouse | `dev_wh` |
| Database | `job_ads` |
| Landing schema | `staging` |
| Transformed schema | `warehouse` |
| Business-facing schema | `marts` |
| dlt user | `extract_loader` |
| dlt role | `job_ads_dlt_role` |
| dbt user | `transformer` |
| dbt role | `job_ads_dbt_role` |

For another project, replace `job_ads` with your project name.

Example:

```text
marketing
marketing_dlt_role
marketing_dbt_role
```

---

## 5. Golden rules

### Principle of least privilege

Use the Snowflake role that is responsible for the task.

| Role | Typical responsibility |
|---|---|
| `SYSADMIN` | Warehouses, databases, schemas |
| `USERADMIN` | Users and roles |
| `SECURITYADMIN` | Grants and role assignments |
| Project-specific role | Actual pipeline/transformation work |

Avoid doing normal project setup with `ACCOUNTADMIN`.

### Separate people from service users

Use dedicated service users:

```text
extract_loader -> dlt
transformer    -> dbt
```

Your own Snowflake login is for you. The service users are for the tools.

### Never commit secrets

Do not commit:

```text
.dlt/secrets.toml
passwords
API keys
private connection files
SQL files containing passwords
```

### Run `dbt init` once per dbt project

If `dbt_code/` already exists and contains `dbt_project.yml`, you normally **reuse that project**.

Do not run `dbt init` again simply because you created a new lecture folder.

---

## 6. Starter `.gitignore`

```gitignore
# Python
.venv/
__pycache__/
*.py[cod]

# dlt secrets
.dlt/
**/.dlt/
**/secrets.toml

# Environment files
.env
.env.*

# Snowflake SQL files containing passwords
**/setup_user.sql
**/setup_dlt_user.sql
**/setup_dbt_user.sql

# dbt generated files
**/target/
**/dbt_packages/
**/logs/

# OS/editor files
.DS_Store
```

> `pyproject.toml` and `uv.lock` are normally useful to commit because they help reproduce the Python environment.

---

## 7. First steps from a blank repo

Open the blank repository in VS Code.

Check Git:

```bash
git status
```

Create the initial folders:

```bash
mkdir sql
mkdir dlt_code
mkdir modeling
```

Create `.gitignore` before adding any secrets.

Then follow:

```text
01_snowflake_foundation.md
        |
        +--> CSV? -> 02_dlt_csv_ingestion.md
        |
        +--> API? -> 03_dlt_api_ingestion.md
                        |
                        v
             04_dimensional_modeling.md
                        |
                        v
                  05_dbt_setup.md
```

---

## 8. Mental model to remember

```text
Snowflake setup = infrastructure + permissions

dlt = Extract + Load

staging = source-shaped landing zone

dimensional model = blueprint

dbt = Transform

warehouse = facts + dimensions

marts = data prepared for a specific business use
```
