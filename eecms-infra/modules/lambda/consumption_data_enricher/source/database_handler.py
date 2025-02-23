import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class DatabaseHandler:

    def __init__(self, region):
        self.table_name = os.getenv('DYNAMO_DB_TABLE')
        self.dynamodb_client = boto3.resource('dynamodb', region_name=region)

    def get_all_customers(self):
        table = self.dynamodb_client.Table(self.table_name)
        response = table.scan()#TODO

        customers = {}
        for item in response.get('Items', []):
            customers[item['billing_metering_point_number']] = item

        return customers
