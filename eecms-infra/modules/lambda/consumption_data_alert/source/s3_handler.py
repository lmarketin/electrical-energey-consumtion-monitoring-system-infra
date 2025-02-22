import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SOURCE_BUCKET = 'postgres-db-consumption-data-exports-bucket'

class S3Handler:

    def __init__(self):
        self.s3 = boto3.client("s3")

    def download_file_from_s3(self, source_bucket, source_key):
        logger.info(f"Downloading extracted report from Bucket:{source_bucket}, with Key:{source_key}")
        response = self.s3.get_object(Bucket=source_bucket, Key=source_key)
        logger.info(f"Downloaded extracted report:{source_key}")

        return response