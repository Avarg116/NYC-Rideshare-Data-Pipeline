select
    pickup_hour,
    pu_location_id,
    touches_cbd,
    pricing_period,
    count(*) as trips,
    sum(trip_minutes) as total_trip_minutes,
    sum(base_passenger_fare) as total_base_fare,
    sum(driver_pay) as total_driver_pay,
    sum(uber_take) as total_uber_take,
    sum(cbd_congestion_fee) as total_cbd_fees
from
    {{ ref('int_trips') }}
group by
    pickup_hour,
    pu_location_id,
    touches_cbd,
    pricing_period
