select
    date_trunc('month', pickup_hour)::date as month,
    borough,
    sum(trips) as trips,
    sum(total_driver_pay) as driver_pay,
    sum(total_uber_take) as uber_take,
    {{ safe_divide('sum(total_driver_pay)', 'sum(total_base_fare)') }} as driver_share
from
    {{ ref('fct_hourly_zone_trips') }}
group by
    month,
    borough
order by
    month,
    borough
