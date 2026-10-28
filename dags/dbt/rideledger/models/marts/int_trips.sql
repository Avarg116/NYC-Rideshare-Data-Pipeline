select
    trips.trip_key,
    date_trunc('hour', trips.pickup_datetime) as pickup_hour,
    trips.pu_location_id,
    case when trips.pickup_datetime < '2025-01-05' then 'pre' else 'post' end as pricing_period,
    pickup_cbd.location_id is not null or dropoff_cbd.location_id is not null as touches_cbd,
    {{ minutes_between('trips.pickup_datetime', 'trips.dropoff_datetime') }} as trip_minutes,
    trips.base_passenger_fare,
    trips.driver_pay,
    trips.base_passenger_fare - trips.driver_pay as uber_take,
    trips.cbd_congestion_fee
from
    {{ ref('stg_uber_trips') }} as trips
left join
    {{ ref('cbd_zones') }} as pickup_cbd
        on trips.pu_location_id = pickup_cbd.location_id
left join
    {{ ref('cbd_zones') }} as dropoff_cbd
        on trips.do_location_id = dropoff_cbd.location_id
where
    trips.base_passenger_fare > 0
    and trips.trip_miles > 0
    and trips.dropoff_datetime > trips.pickup_datetime
