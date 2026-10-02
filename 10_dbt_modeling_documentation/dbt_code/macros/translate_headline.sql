{% macro translate_headline(column) %} -- takes a column name as its argument
-- The {{ column }} syntax inserts that argument into the generated SQL

    case
        when {{ column }} = 'Data engineer'  -- The CASE expression checks whether the column’s value is 'Data engineer'
        then 'Junior data engineer' -- If it is, the result is 'Junior data engineer'

        else {{ column }} -- otherwise, the expression returns the column’s original value
    end

{% endmacro %}

-- The macro therefore changes one specific headline while leaving other values unchanged