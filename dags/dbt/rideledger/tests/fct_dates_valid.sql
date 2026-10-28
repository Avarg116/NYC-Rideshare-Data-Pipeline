select
    *
from
    {{ref('fct_hourly_zone_trips')}}
where
    pickup_hour < '2024-10-01'
    or pickup_hour >= '2025-04-01'
