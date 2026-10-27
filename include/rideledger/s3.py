import os
import sys

import boto3
from botocore.exceptions import ClientError

def s3_key(year, month, filename):
    return f"raw/hvfhv/year={year}/month={month:02d}/{filename}"

def file_exists(s3, bucket, key):
    try:
        s3.head_object(Bucket=bucket, Key=key)
        return True
    except ClientError:
        return False

def upload_month(path, year, month):
    bucket = os.environ["S3_BUCKET"]
    key = s3_key(year, month, os.path.basename(path))
    s3 = boto3.client("s3")

    if file_exists(s3, bucket, key):
        print(f"already in s3, skipping: s3://{bucket}/{key}")
        return key

    s3.upload_file(path, bucket, key)
    print(f"uploaded: s3://{bucket}/{key}")
    return key

if __name__ == "__main__":
    upload_month(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
