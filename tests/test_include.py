import pandas as pd

from include.rideledger.load import COLUMNS, clean_batch
from include.rideledger.s3 import s3_key


def test_s3_key():
    assert s3_key(2024, 3, "fhvhv_tripdata_2024-03.parquet") == "raw/hvfhv/year=2024/month=03/fhvhv_tripdata_2024-03.parquet"


def test_clean_batch():
    df = pd.DataFrame({col: [1, 2] for col in COLUMNS if col not in ["pu_location_id", "do_location_id", "cbd_congestion_fee", "source_file"]})
    df["hvfhs_license_num"] = ["HV0003", "HV0005"]
    df["PULocationID"] = [161, 236]
    df["DOLocationID"] = [237, 48]

    result = clean_batch(df, "fhvhv_tripdata_2024-10.parquet")

    assert len(result) == 1
    assert result["pu_location_id"].iloc[0] == 161
    assert result["cbd_congestion_fee"].isna().all()
