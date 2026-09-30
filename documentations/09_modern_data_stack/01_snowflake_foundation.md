# 01 — Snowflake Foundation: Warehouse, Database, Schemas, Users and Roles

Use this guide when you are starting a new Snowflake-backed project.

Course reference: `05_users_and_roles`

---

## Goal

By the end of this guide you should have:

```text
Warehouse:   dev_wh
Database:    PROJECT_DB
Schema:      staging
dlt role:    project_dlt_role
dlt user:    extract_loader
```

Later, dbt will add:

```text
Schema:      warehouse
Schema:      marts
dbt role:    project_dbt_role
dbt user:    transformer
```

---

# Part 1 — Create the warehouse, database and staging schema

Create:

```text
sql/00_setup_warehouse_database.sql
```

Use `SYSADMIN` because this role is responsible for warehouses, databases and schemas.

```sql
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS dev_wh
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Development warehouse';

CREATE DATABASE IF NOT EXISTS PROJECT_DB;

CREATE SCHEMA IF NOT EXISTS PROJECT_DB.staging;
```

Replace `PROJECT_DB` with your real database name, for example:

```text
movies
job_ads
ifood
```

### Why `AUTO_SUSPEND = 60`?

The warehouse suspends after 60 seconds of inactivity, which helps avoid unnecessary compute cost.

### Why `staging`?

`staging` is the landing zone. dlt loads source data here before dbt transforms it.

---

# Part 2 — Create the dlt role

Create:

```text
sql/01_setup_roles.sql
```

```sql
USE ROLE USERADMIN;

CREATE ROLE IF NOT EXISTS project_dlt_role
    COMMENT = 'Role used by dlt to load data into PROJECT_DB.staging';
```

Example:

```sql
CREATE ROLE IF NOT EXISTS job_ads_dlt_role;
```

---

# Part 3 — Grant the dlt role the minimum required privileges

Still in `sql/01_setup_roles.sql`:

```sql
USE ROLE SECURITYADMIN;

GRANT USAGE ON WAREHOUSE dev_wh
TO ROLE project_dlt_role;

GRANT USAGE ON DATABASE PROJECT_DB
TO ROLE project_dlt_role;

GRANT USAGE ON SCHEMA PROJECT_DB.staging
TO ROLE project_dlt_role;

GRANT CREATE TABLE ON SCHEMA PROJECT_DB.staging
TO ROLE project_dlt_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA PROJECT_DB.staging
TO ROLE project_dlt_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON FUTURE TABLES IN SCHEMA PROJECT_DB.staging
TO ROLE project_dlt_role;
```

## What do these privileges mean?

| Privilege | Meaning |
|---|---|
| `USAGE ON WAREHOUSE` | The role may use Snowflake compute |
| `USAGE ON DATABASE` | The role may reference the database |
| `USAGE ON SCHEMA` | The role may reference objects inside the schema |
| `CREATE TABLE` | dlt may create destination tables |
| `SELECT` | Read rows |
| `INSERT` | Add rows |
| `UPDATE` | Change rows |
| `DELETE` | Remove rows |

`USAGE` does **not** mean the role can automatically read every table.

---

# Part 4 — Create the dlt service user

This file contains a password, so keep it separate.

Create:

```text
sql/02_setup_dlt_user.sql
```

Add it to `.gitignore`:

```gitignore
**/02_setup_dlt_user.sql
```

Then:

```sql
USE ROLE USERADMIN;

CREATE USER IF NOT EXISTS extract_loader
    PASSWORD = '<YOUR_STRONG_PASSWORD>'
    DEFAULT_WAREHOUSE = dev_wh
    COMMENT = 'Service user used by dlt';
```

Do not push this password to GitHub.

---

# Part 5 — Assign the role to the dlt user

This statement is safe to keep in the role/grants file because it contains no password:

```sql
USE ROLE SECURITYADMIN;

GRANT ROLE project_dlt_role
TO USER extract_loader;
```

Optional default role:

```sql
USE ROLE USERADMIN;

ALTER USER extract_loader
SET DEFAULT_ROLE = project_dlt_role;
```

---

# Part 6 — Verify the grants

Create:

```text
sql/03_check_grants.sql
```

```sql
SHOW GRANTS TO ROLE project_dlt_role;
SHOW GRANTS TO USER extract_loader;
SHOW FUTURE GRANTS IN SCHEMA PROJECT_DB.staging;
```

Check objects:

```sql
USE ROLE SYSADMIN;

SHOW WAREHOUSES LIKE 'DEV_WH';
SHOW DATABASES LIKE 'PROJECT_DB';
SHOW SCHEMAS IN DATABASE PROJECT_DB;
```

---

# Part 7 — Optional reader role

If someone should only read the data:

```sql
USE ROLE USERADMIN;

CREATE ROLE IF NOT EXISTS project_reader;

USE ROLE SECURITYADMIN;

GRANT USAGE ON WAREHOUSE dev_wh
TO ROLE project_reader;

GRANT USAGE ON DATABASE PROJECT_DB
TO ROLE project_reader;

GRANT USAGE ON SCHEMA PROJECT_DB.staging
TO ROLE project_reader;

GRANT SELECT ON ALL TABLES IN SCHEMA PROJECT_DB.staging
TO ROLE project_reader;

GRANT SELECT ON FUTURE TABLES IN SCHEMA PROJECT_DB.staging
TO ROLE project_reader;
```

Assign it:

```sql
GRANT ROLE project_reader TO USER <YOUR_USERNAME>;
```

---

# Recommended role model

```text
Snowflake system roles
        |
        | create objects / manage grants
        v
project_dlt_role
        |
        | assigned to
        v
 extract_loader
```

Later:

```text
project_dlt_role
        |
        | inherited by
        v
project_dbt_role
        |
        v
   transformer
```

This lets dbt read staging data while giving it additional privileges for transformed schemas.

---

# Final checklist

Before moving to dlt:

- [ ] `dev_wh` exists
- [ ] database exists
- [ ] `staging` schema exists
- [ ] dlt role exists
- [ ] `extract_loader` exists
- [ ] dlt role is assigned to `extract_loader`
- [ ] dlt role has warehouse `USAGE`
- [ ] dlt role has database and schema `USAGE`
- [ ] dlt role can create and modify staging tables
- [ ] password file is ignored by Git
