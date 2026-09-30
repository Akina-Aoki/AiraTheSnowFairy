{% macro capitalize_first_letter(column) %}  -- generates a SQL CASE expression for the supplied column
    case
        when {{ column }} is null
        then null                -- If the column value is NULL, it returns NULL
        else upper(substr({{ column }}, 1, 1)) || lower(substr({{ column }}, 2))
    end     -- Otherwise, it converts the first character to uppercase and the rest of the string to lowercase, then concatenates them
{% endmacro %}