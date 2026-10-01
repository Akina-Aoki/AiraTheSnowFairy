-- Overrides dbt's default schema naming.
-- Without this macro:
--   warehouse + warehouse -> WAREHOUSE_WAREHOUSE
--
-- With this macro:
--   +schema: warehouse -> WAREHOUSE
--   +schema: marts     -> MARTS
--
-- If no custom +schema is given, dbt uses the schema from profiles.yml.
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}