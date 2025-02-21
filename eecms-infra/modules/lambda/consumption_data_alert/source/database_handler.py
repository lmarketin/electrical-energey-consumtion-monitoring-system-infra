import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class DatabaseHandler:

    def __init__(self, region):
        self.database_name = "customers"#os.getenv('')TODO
        self.dynamodb_client = boto3.resource('dynamodb', region_name=region)

    def get_all_customers(self):
        table = self.dynamodb_client.Table(self.database_name)
        response = table.scan()#TODO

        customers = {}
        for item in response.get('Items', []):
            customers[item['x_api_key']] = item

        return customers
