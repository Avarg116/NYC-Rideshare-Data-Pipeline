select
    *
from
    {{ref('fct_hourly_zone_trips')}}
where
    total_driver_pay < 0
