create table raw.uber_trips (
    request_datetime      timestamp,
    pickup_datetime       timestamp not null,
    dropoff_datetime      timestamp,
    pu_location_id        integer,
    do_location_id        integer,
    trip_miles            numeric(8,2),
    trip_time             integer,
    base_passenger_fare   numeric(10,2),
    tolls                 numeric(10,2),
    bcf                   numeric(10,2),
    sales_tax             numeric(10,2),
    congestion_surcharge  numeric(10,2),
    airport_fee           numeric(10,2),
    cbd_congestion_fee    numeric(10,2),
    tips                  numeric(10,2),
    driver_pay            numeric(10,2),
    shared_request_flag   char(1),
    shared_match_flag     char(1),
    source_file           text not null,
    loaded_at             timestamp not null default now()
) partition by range (pickup_datetime);

create table raw.uber_trips_default partition of raw.uber_trips default;

create table raw.load_log (
    source_file   text primary key,
    year_month    date not null,
    rows_in_file  bigint,
    rows_loaded   bigint,
    loaded_at     timestamp default now()
);
