-- duckdb
create or replace view trips as
select * from read_parquet('data/fhvhv_tripdata_2024-10.parquet');

select * from trips limit 10;

describe trips;

select count(*) from trips;

-- HV0003 = Uber, HV0005 = Lyft
select
    hvfhs_license_num,
    count(*) as num_trips,
    round(count(*) * 100.0 / (select count(*) from trips), 2) as percent
from trips
group by hvfhs_license_num
order by num_trips desc;
-- uber = 15,145,313 trips

-- nulls, min, max, avg for every column (uber only)
summarize
select * from trips
where hvfhs_license_num = 'HV0003';

select count(*) from trips
where hvfhs_license_num = 'HV0003' and base_passenger_fare <= 0;

select count(*) from trips
where hvfhs_license_num = 'HV0003' and trip_miles = 0;

select count(*) from trips
where hvfhs_license_num = 'HV0003' and dropoff_datetime <= pickup_datetime;

select count(*) from trips
where hvfhs_license_num = 'HV0003' and driver_pay > base_passenger_fare;

-- In each borough which 5 zones have the most Uber pickups
with zone_trips as (
    select
        z.Borough,
        z.Zone,
        count(*) as num_trips
    from trips t
    join read_csv_auto('data/taxi_zone_lookup.csv') z
        on t.PULocationID = z.LocationID
    where t.hvfhs_license_num = 'HV0003'
    group by z.Borough, z.Zone
),

ranked as (
    select
        *,
        rank() over (partition by Borough order by num_trips desc) as zone_rank
    from zone_trips
)

select * from ranked
where zone_rank <= 5
order by Borough, zone_rank;
