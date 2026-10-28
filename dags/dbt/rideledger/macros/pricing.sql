{% macro safe_divide(numerator, denominator, scale=4) %}
    ({{numerator}} / nullif({{denominator}}, 0))::decimal(16, {{ scale }})
{% endmacro %}

{% macro minutes_between(start_time, end_time, scale=2) %}
    (extract(epoch from ({{end_time}} - {{start_time}})) / 60)::decimal(16, {{ scale }})
{% endmacro %}
