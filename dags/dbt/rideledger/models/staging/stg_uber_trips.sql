select
    {{
        dbt_utils.generate_surrogate_key([
            'pickup_datetime',
            'dropoff_datetime',
            'pu_location_id',
            'do_location_id',
            'base_passenger_fare',
            'driver_pay',
            'source_file'
        ])
    }} as trip_key,
    pickup_datetime,
    dropoff_datetime,
    pu_location_id,
    do_location_id,
    trip_miles,
    base_passenger_fare,
    driver_pay,
    cbd_congestion_fee
from
    {{ source('raw', 'uber_trips') }}
