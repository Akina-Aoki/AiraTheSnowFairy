{% macro translate_headline(column) %}

    case
        when {{ column }} = 'Data engineer'
        then 'Junior data engineer'

        else {{ column }}
    end

{% endmacro %}