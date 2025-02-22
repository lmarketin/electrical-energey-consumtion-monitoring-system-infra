import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class DatabaseHandler:

    def __init__(self, region):
        self.database_name = "customers"#os.getenv('')TODO
        self.dynamodb_client = boto3.resource('dynamodb', region_name=region)

    def get_active_customers(self):
        logger.info(f"Fetching customers data from DynamoDB customers table")
        table = self.dynamodb_client.Table(self.database_name)
        response = table.scan()#TODO

        items = response.get('Items', [])
        customers_dict = {}
        for item in items:
            hash_key_value = int(item['billing_metering_point_number'])
            item_copy = item.copy()
            item_copy.pop('billing_metering_point_number', None)
            customers_dict[hash_key_value] = item_copy

        active_customers_dict = {
            billing_metering_point_number: customer for billing_metering_point_number,
            customer in customers_dict.items() if customer.get("active") is True
        }

        logger.info(f"Fetched active customers data from DynamoDB with "
                    f"hash_key(billing_metering_point_number) as key: {active_customers_dict}")

        return active_customers_dict
