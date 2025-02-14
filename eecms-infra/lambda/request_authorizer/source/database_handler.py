import boto3
import logging

DB_COLUMN_NAME = 'x_api_key'

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class DatabaseHandler:

    def __init__(self, region):
        self.database_name = "customers"
        self.dynamodb_client = boto3.resource('dynamodb', region_name=region)

    def get_customer_by_x_api_key(self, x_api_key):
        result = self.dynamodb_client.Table(self.database_name).get_item(
            Key={
                DB_COLUMN_NAME: x_api_key
            }
        )
        customer_info = result.get('Item')
        if customer_info is None:
            raise NoCustomerInDBException(f"No customer found with x_api_key:{x_api_key}")

        return customer_info

class NoCustomerInDBException(Exception):
    pass
