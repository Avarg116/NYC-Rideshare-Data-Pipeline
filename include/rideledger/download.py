import os
import sys

import requests

URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/fhvhv_tripdata_{year}-{month:02d}.parquet"

def file_url(year, month):
    return URL.format(year=year, month=month)

def download_month(year, month, data_dir="data"):
    url = file_url(year, month)
    path = os.path.join(data_dir, os.path.basename(url))

    if os.path.exists(path):
        print(f"already downloaded, skipping: {path}")
        return path

    os.makedirs(data_dir, exist_ok=True)
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(path, "wb") as f:
            for chunk in r.iter_content(chunk_size=1024 * 1024):
                f.write(chunk)

    print(f"downloaded: {path}")
    return path

if __name__ == "__main__":
    download_month(int(sys.argv[1]), int(sys.argv[2]))
