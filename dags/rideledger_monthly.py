from datetime import timedelta

from airflow.sdk import dag, task
from pendulum import datetime
import requests

from include.rideledger.download import download_month, file_url
from include.rideledger.load import load_month
from include.rideledger.s3 import upload_month

DATA_DIR = "/tmp/data"

@dag(
    start_date=datetime(2024, 10, 1),
    end_date=datetime(2025, 3, 1),
    schedule="@monthly",
    catchup=True,
    max_active_runs=1,
    default_args={"owner": "rideledger", "retries": 2, "retry_delay": timedelta(minutes=5)},
    tags=["rideledger"],
)
def rideledger_monthly():
    @task.sensor(poke_interval=300, timeout=60 * 60 * 24, mode="reschedule")
    def check_file_available(**context):
        d = context["logical_date"]
        return requests.head(file_url(d.year, d.month)).status_code == 200

    @task
    def download_parquet(**context):
        d = context["logical_date"]
        return download_month(d.year, d.month, DATA_DIR)

    @task
    def upload_raw_to_s3(path, **context):
        d = context["logical_date"]
        return upload_month(path, d.year, d.month)

    @task
    def load_to_postgres(path, **context):
        d = context["logical_date"]
        load_month(path, d.year, d.month)

    check = check_file_available()
    path = download_parquet()
    upload = upload_raw_to_s3(path)
    load = load_to_postgres(path)

    check >> path >> upload >> load

rideledger_monthly()
