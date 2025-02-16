import boto3
import logging

DB_TABLE_NAME = 'customers'
DB_COLUMN_NAME = 'billing_metering_point_number'

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class DatabaseHandler:

    def __init__(self, region):
        self.dynamodb_client = boto3.resource('dynamodb', region_name=region)

    def get_customer_by_billing_metering_point_number(self, billing_metering_point_number):
        logger.info(f"Fetching customer info with billing_metering_point_number:{billing_metering_point_number}")
        result = self.dynamodb_client.Table(DB_TABLE_NAME).get_item(
            Key={
                DB_COLUMN_NAME: int(billing_metering_point_number)
            }
        )
        customer_info = result.get('Item')
        logger.info(f"Fetched customer info:{customer_info}")
        if customer_info is None:
            message = f"Customer with billing_metering_point_number:{billing_metering_point_number} not found"
            logger.error(message)
            raise NoCustomerInDBException(message)

        return customer_info

class NoCustomerInDBException(Exception):
    pass
