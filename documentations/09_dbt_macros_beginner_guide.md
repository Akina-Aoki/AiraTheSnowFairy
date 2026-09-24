# dbt Macros — Beginner Guide

## What is a macro in dbt?

A **macro** in dbt is a reusable piece of SQL logic.

Instead of writing the same SQL code again and again inside different models, you can write the logic once inside the `macros/` folder and then call it wherever you need it.

You can think of a macro like a small SQL function.

---

## Where macros live

In this project, macros are stored here:

```text
09_lecture_dbt/
└── dbt_code/
    ├── macros/
    │   ├── generate_schema_name.sql
    │   ├── string_utils.sql
    │   └── translate_headline.sql
    │
    └── models/
```

dbt automatically looks inside the `macros/` folder when the project runs.

---

# 1. `translate_headline.sql`

This macro contains transformation logic for job titles.

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

## What it does

The macro checks a column value.

If the value is:

```text
Data engineer
```

it changes it to:

```text
Junior data engineer
```

Otherwise, it keeps the original value.

---

## How the model uses it

Inside `updated_headline_macro.sql`:

```sql
{{ translate_headline('headline') }} AS updated_job_title
```

dbt finds the macro named:

```text
translate_headline
```

and inserts its SQL logic into the model.

Conceptually:

```text
updated_headline_macro.sql
        ↓
calls translate_headline()
        ↓
dbt finds macros/translate_headline.sql
        ↓
dbt inserts the CASE logic
        ↓
Snowflake runs the final SQL
```

This makes the transformation reusable.

---

# 2. `string_utils.sql`

This file contains another reusable macro:

```sql
{% macro capitalize_first_letter(column) %}

    case
        when {{ column }} is null
        then null

        else upper(substr({{ column }}, 1, 1))
             || lower(substr({{ column }}, 2))
    end

{% endmacro %}
```

## What it does

It formats text so that:

```text
DATA ENGINEER
```

could become:

```text
Data engineer
```

The macro:

1. keeps `NULL` values as `NULL`
2. makes the first letter uppercase
3. makes the rest lowercase

You can use it in a model like this:

```sql
{{ capitalize_first_letter('headline') }}
```

If you are not calling this macro in any model yet, it simply stays available for future use.

---

# 3. `generate_schema_name.sql`

This macro changes how dbt creates schema names.

Your `profiles.yml` uses:

```text
schema: warehouse
```

and your `dbt_project.yml` may contain:

```yaml
staging:
  +schema: staging

refined:
  +schema: warehouse
```

By default, dbt may combine these names.

For example:

```text
warehouse + staging
        ↓
WAREHOUSE_STAGING
```

and:

```text
warehouse + warehouse
        ↓
WAREHOUSE_WAREHOUSE
```

The custom `generate_schema_name` macro changes that behavior.

Example:

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

With this macro, dbt uses the schema name you explicitly configure.

So:

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

instead of creating:

```text
WAREHOUSE_STAGING
WAREHOUSE_WAREHOUSE
```

---

# How macros affect the dbt process

Without macros:

```text
Raw Snowflake table
        ↓
dbt model
        ↓
SQL logic written directly inside the model
        ↓
Snowflake
```

With macros:

```text
Raw Snowflake table
        ↓
dbt model
        ↓
model calls a macro
        ↓
dbt finds the macro
        ↓
dbt inserts the reusable SQL logic
        ↓
Snowflake runs the final SQL
```

The macro itself does not usually create a table or view.

Instead, it helps dbt **build the SQL** that will be sent to Snowflake.

---

# How macros fit into this project

Your current flow is:

```text
JobTech API
    ↓
dlt
    ↓
JOB_ADS.STAGING.DATA_FIELD_JOB_ADS
    ↓
original_headline.sql
    ↓
updated_headline.sql
    ↓
updated_headline_macro.sql
```

The macro version works like this:

```text
original_headline
        ↓
updated_headline_macro.sql
        ↓
translate_headline()
        ↓
CASE transformation
        ↓
WAREHOUSE.UPDATED_HEADLINE_MACRO
```

The `generate_schema_name` macro works separately in the background and controls **where dbt creates models**.

---

# `ref()` vs macro

These are related to dbt, but they do different jobs.

## `ref()`

Example:

```sql
{{ ref('original_headline') }}
```

This means:

> Use another dbt model as the source.

It also creates a dependency between models.

Example:

```text
original_headline
        ↓
updated_headline
```

---

## Macro

Example:

```sql
{{ translate_headline('headline') }}
```

This means:

> Run reusable SQL logic here.

So:

```text
ref()   = connects dbt models together

macro   = reuses SQL logic
```

---

# Why macros are useful

Macros help you:

- avoid repeating SQL
- keep transformation logic consistent
- make models easier to read
- reuse the same logic in many models
- change logic in one place instead of many files

This follows the DRY principle:

```text
DRY = Don't Repeat Yourself
```

---

# Simple mental model

Think of dbt like this:

```text
MODEL
"What data should I build?"

REF()
"Which dbt model does this depend on?"

MACRO
"What reusable SQL logic should I insert?"

SNOWFLAKE
"Run the final SQL."
```

---

# In your project

These macros currently have different responsibilities:

| Macro | Purpose |
|---|---|
| `translate_headline()` | Changes specific job-title values |
| `capitalize_first_letter()` | Formats text capitalization |
| `generate_schema_name()` | Controls the Snowflake schema names dbt creates |

The first two are **transformation macros**.

`generate_schema_name()` is a **dbt behavior/configuration macro** because it changes how dbt decides schema names.

---

# Key takeaway

A dbt macro is reusable SQL logic written with Jinja.

You define it once:

```sql
{% macro my_macro(...) %}
    ...
{% endmacro %}
```

and call it with:

```sql
{{ my_macro(...) }}
```

dbt then compiles the macro into normal SQL before sending the query to Snowflake.
