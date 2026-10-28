select
    pricing_period,
    touches_cbd,
    {{ safe_divide('sum(trips)', 'count(distinct pickup_hour::date)', 0) }} as trips_per_day,
    {{ safe_divide('sum(total_base_fare)', 'sum(trips)', 2) }} as avg_fare,
    {{ safe_divide('sum(total_trip_minutes)', 'sum(trips)', 2) }} as avg_trip_minutes,
    {{ safe_divide('sum(total_driver_pay)', 'sum(total_base_fare)') }} as driver_share
from
    {{ ref('fct_hourly_zone_trips') }}
group by
    pricing_period,
    touches_cbd
