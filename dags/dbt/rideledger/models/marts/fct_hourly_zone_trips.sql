select
    summary.*,
    zones.borough,
    zones.zone
from
    {{ ref('int_trips_hourly_summary') }} as summary
join
    {{ ref('stg_taxi_zones') }} as zones
        on summary.pu_location_id = zones.location_id
order by
    summary.pickup_hour
