# 05 — Set Up dbt Core with Snowflake

Use this after:

1. dlt is successfully loading data into `staging`;
2. you have a dimensional model or transformation plan.

Course reference: `09_setup_dbt`

---

## Goal

By the end you should have:

```text
Snowflake:
PROJECT_DB.staging
PROJECT_DB.warehouse
PROJECT_DB.marts

Users/roles:
extract_loader     -> project_dlt_role
transformer        -> project_dbt_role

VS Code:
dbt_code/
└── dbt_project.yml

Home directory:
~/.dbt/profiles.yml
```

---

# Part 1 — Create the dbt role

Create:

```text
sql/04_setup_dbt_role.sql
```

```sql
USE ROLE USERADMIN;

CREATE ROLE IF NOT EXISTS project_dbt_role
    COMMENT = 'Role used by dbt transformations';
```

---

# Part 2 — Let dbt read the dlt staging layer

The course pattern lets the dbt role inherit the dlt role:

```sql
USE ROLE SECURITYADMIN;

GRANT ROLE project_dlt_role
TO ROLE project_dbt_role;
```

Conceptually:

```text
project_dlt_role
    |
    | inherited privileges
    v
project_dbt_role
```

---

# Part 3 — Create the warehouse schema

```sql
USE ROLE SYSADMIN;

USE DATABASE PROJECT_DB;

CREATE SCHEMA IF NOT EXISTS warehouse;
```

Grant dbt permission:

```sql
USE ROLE SECURITYADMIN;

GRANT USAGE,
      CREATE TABLE,
      CREATE VIEW
ON SCHEMA PROJECT_DB.warehouse
TO ROLE project_dbt_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA PROJECT_DB.warehouse
TO ROLE project_dbt_role;

GRANT SELECT
ON ALL VIEWS IN SCHEMA PROJECT_DB.warehouse
TO ROLE project_dbt_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON FUTURE TABLES IN SCHEMA PROJECT_DB.warehouse
TO ROLE project_dbt_role;

GRANT SELECT
ON FUTURE VIEWS IN SCHEMA PROJECT_DB.warehouse
TO ROLE project_dbt_role;
```

---

# Part 4 — Create the marts schema

```sql
USE ROLE SYSADMIN;

USE DATABASE PROJECT_DB;

CREATE SCHEMA IF NOT EXISTS marts;
```

Grant dbt access:

```sql
USE ROLE SECURITYADMIN;

GRANT USAGE,
      CREATE TABLE,
      CREATE VIEW
ON SCHEMA PROJECT_DB.marts
TO ROLE project_dbt_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA PROJECT_DB.marts
TO ROLE project_dbt_role;

GRANT SELECT
ON ALL VIEWS IN SCHEMA PROJECT_DB.marts
TO ROLE project_dbt_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON FUTURE TABLES IN SCHEMA PROJECT_DB.marts
TO ROLE project_dbt_role;

GRANT SELECT
ON FUTURE VIEWS IN SCHEMA PROJECT_DB.marts
TO ROLE project_dbt_role;
```

---

# Part 5 — Create the dbt service user

Create a password-containing file:

```text
sql/05_setup_dbt_user.sql
```

Add it to `.gitignore`.

```sql
USE ROLE USERADMIN;

CREATE USER IF NOT EXISTS transformer
    PASSWORD = '<YOUR_STRONG_PASSWORD>'
    DEFAULT_WAREHOUSE = dev_wh
    DEFAULT_NAMESPACE = 'PROJECT_DB.warehouse'
    COMMENT = 'Service user used by dbt'
    DEFAULT_ROLE = 'project_dbt_role';
```

Assign the role:

```sql
USE ROLE SECURITYADMIN;

GRANT ROLE project_dbt_role
TO USER transformer;
```

---

# Part 6 — Test Snowflake permissions first

```sql
USE ROLE project_dbt_role;
USE WAREHOUSE dev_wh;

SELECT *
FROM PROJECT_DB.staging.<YOUR_STAGING_TABLE>
LIMIT 10;
```

Test table creation:

```sql
USE DATABASE PROJECT_DB;
USE SCHEMA warehouse;

CREATE TABLE test_dbt_permissions (id INTEGER);
DROP TABLE test_dbt_permissions;
```

If both work, Snowflake permissions are ready.

---

# Part 7 — Install dbt Core and Snowflake adapter

Activate the project virtual environment.

Windows Git Bash:

```bash
source .venv/Scripts/activate
```

Install:

```bash
uv pip install dbt-core dbt-snowflake
```

Verify:

```bash
dbt --version
```

---

# Part 8 — Initialize the dbt project

From the folder where you want `dbt_code/`:

```bash
dbt init dbt_code
```

This creates:

```text
dbt_code/
├── analyses/
├── macros/
├── models/
├── seeds/
├── snapshots/
├── tests/
└── dbt_project.yml
```

It also creates or uses:

```text
~/.dbt/profiles.yml
```

---

# Important: when should I run `dbt init`?

Run it when creating a **new dbt project**.

If you already have:

```text
dbt_code/dbt_project.yml
```

you already have a dbt project.

Normally:

```text
new lecture folder != new dbt project
```

Reuse or move the existing `dbt_code` project if the course reorganizes folders.

---

# Part 9 — Configure `profiles.yml`

File:

```text
~/.dbt/profiles.yml
```

On Windows this is under your user home directory, not inside the Git repository.

```yaml
dbt_snowflake:
  target: dev

  outputs:
    dev:
      type: snowflake
      account: <ACCOUNT_IDENTIFIER>
      user: transformer
      password: <PASSWORD>
      role: project_dbt_role
      database: PROJECT_DB
      warehouse: dev_wh
      schema: staging
      client_session_keep_alive: false
```

This file contains credentials.

Do not copy it into the Git repository.

---

# Part 10 — Connect the dbt project to the profile

Open:

```text
dbt_code/dbt_project.yml
```

Set:

```yaml
profile: "dbt_snowflake"
```

Example:

```yaml
name: "dbt_code"
version: "1.0.0"

profile: "dbt_snowflake"

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

clean-targets:
  - "target"
  - "dbt_packages"

models:
  dbt_code:
    staging:
      schema: staging
      materialized: view

    warehouse:
      schema: warehouse
      materialized: table

    marts:
      schema: marts
      materialized: table
```

---

# Part 11 — Test the connection

Enter the dbt project:

```bash
cd dbt_code
```

Run:

```bash
dbt debug
```

Fix connection issues before writing models.

---

# Part 12 — Add `dbt_utils` when needed

Create:

```text
dbt_code/packages.yml
```

Course example:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.2.0
```

Then:

```bash
dbt deps
```

For future projects, use a package version compatible with that project rather than assuming an old version is current.

---

# Part 13 — Add the custom schema macro

Create:

```text
dbt_code/macros/generate_schema_name.sql
```

```sql
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

This allows custom schema names such as `warehouse` and `marts` to remain exactly those names.

---

# Part 14 — Recommended dbt model folders

```text
dbt_code/models/
├── staging/
│   └── ...
├── warehouse/
│   ├── dim_...
│   └── fct_...
└── marts/
    └── mart_...
```

Mental model:

```text
staging source
     |
     v
staging dbt models
     |
     v
dimensions + facts
     |
     v
marts
```

---

# Part 15 — Useful dbt commands

Run from inside `dbt_code/`.

Connection:

```bash
dbt debug
```

Parse:

```bash
dbt parse
```

Run all models:

```bash
dbt run
```

Run one model:

```bash
dbt run --select my_model
```

Preview a model:

```bash
dbt show --select my_model
```

Limit preview:

```bash
dbt show --select my_model --limit 20
```

Tests:

```bash
dbt test
```

Build:

```bash
dbt build
```

Dependencies:

```bash
dbt deps
```

Clean:

```bash
dbt clean
```

---

# Part 16 — VS Code setup

Install:

```text
dbt Power User
```

Optional file associations:

```json
"files.associations": {
    "*.sql": "jinja-sql",
    "*.yml": "jinja-yaml"
}
```

---

# Part 17 — What dbt files should be committed?

Commit:

```text
dbt_project.yml
models/
macros/
tests/
seeds/
snapshots/
packages.yml
```

Ignore generated files:

```gitignore
**/target/
**/logs/
**/dbt_packages/
```

Do not commit credentials from:

```text
~/.dbt/profiles.yml
```

---

# Final checklist

Snowflake:

- [ ] dbt role exists
- [ ] dbt user exists
- [ ] dbt role can read staging
- [ ] `warehouse` schema exists
- [ ] `marts` schema exists
- [ ] dbt role can create tables/views in transformed schemas

Local:

- [ ] `dbt-core` installed
- [ ] `dbt-snowflake` installed
- [ ] `dbt_code/` initialized
- [ ] `profiles.yml` configured
- [ ] `dbt_project.yml` points to correct profile
- [ ] custom schema macro added if needed
- [ ] `dbt debug` succeeds
- [ ] generated dbt folders are ignored by Git
