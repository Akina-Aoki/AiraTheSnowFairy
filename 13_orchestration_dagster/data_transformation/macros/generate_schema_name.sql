-- Overrides dbt's default schema naming.
-- Without this macro:
--   warehouse + warehouse -> WAREHOUSE_WAREHOUSE
--
-- With this macro:
--   +schema: warehouse -> WAREHOUSE
--   +schema: marts     -> MARTS
--
-- If no custom +schema is given, dbt uses the schema from profiles.yml.
-- It assigns target.schema to default_schema, then checks whether custom_schema_name is none. 
-- If so, it returns the default schema; otherwise, 
-- it returns the custom schema name after removing leading and trailing whitespace with trim.
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}