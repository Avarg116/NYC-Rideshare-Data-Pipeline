import io
import os
import sys
from datetime import date

import psycopg
import pyarrow.parquet as pq

BATCH_SIZE = 500_000

COLUMNS = [
    "request_datetime",
    "pickup_datetime",
    "dropoff_datetime",
    "pu_location_id",
    "do_location_id",
    "trip_miles",
    "trip_time",
    "base_passenger_fare",
    "tolls",
    "bcf",
    "sales_tax",
    "congestion_surcharge",
    "airport_fee",
    "cbd_congestion_fee",
    "tips",
    "driver_pay",
    "shared_request_flag",
    "shared_match_flag",
    "source_file",
]

def get_connection():
    return psycopg.connect(
        host="localhost",
        port=5433,
        dbname="warehouse",
        user="loader_role",
        password=os.environ["LOADER_PASSWORD"],
    )

def create_partition(cur, table, year, month):
    start = date(year, month, 1)
    if month == 12:
        end = date(year + 1, 1, 1)
    else:
        end = date(year, month + 1, 1)

    cur.execute(f"""
        create table if not exists {table}
        partition of raw.uber_trips
        for values from ('{start}') to ('{end}')
    """)

def clean_batch(df, source_file):
    df = df[df["hvfhs_license_num"] == "HV0003"]

    df = df.rename(columns={
        "PULocationID": "pu_location_id",
        "DOLocationID": "do_location_id",
    })

    if "cbd_congestion_fee" not in df.columns:
        df["cbd_congestion_fee"] = None

    df["source_file"] = source_file
    return df[COLUMNS]

def load_month(path, year, month):
    source_file = os.path.basename(path)
    parquet_file = pq.ParquetFile(path)
    rows_in_file = parquet_file.metadata.num_rows
    table = f"raw.uber_trips_{year}_{month:02d}"
    rows_loaded = 0

    with get_connection() as conn:
        with conn.cursor() as cur:
            create_partition(cur, table, year, month)

            cur.execute(f"truncate {table}")

            with cur.copy(f"copy raw.uber_trips ({', '.join(COLUMNS)}) from stdin with (format csv)") as copy:
                for batch in parquet_file.iter_batches(batch_size=BATCH_SIZE):
                    df = clean_batch(batch.to_pandas(), source_file)

                    buf = io.StringIO()
                    df.to_csv(buf, index=False, header=False)
                    copy.write(buf.getvalue())

                    rows_loaded += len(df)
                    print(f"loaded {rows_loaded:,} rows")

            cur.execute("delete from raw.load_log where source_file = %s", (source_file,))
            cur.execute(
                "insert into raw.load_log (source_file, year_month, rows_in_file, rows_loaded) values (%s, %s, %s, %s)",
                (source_file, date(year, month, 1), rows_in_file, rows_loaded),
            )

            cur.execute(f"select count(*) from {table}")
            rows_in_table = cur.fetchone()[0]

    print(f"rows in file: {rows_in_file:,}")
    print(f"uber rows loaded: {rows_loaded:,}")
    print(f"rows in {table}: {rows_in_table:,}")

    if rows_in_table != rows_loaded:
        raise Exception("counts don't match")

if __name__ == "__main__":
    load_month(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
