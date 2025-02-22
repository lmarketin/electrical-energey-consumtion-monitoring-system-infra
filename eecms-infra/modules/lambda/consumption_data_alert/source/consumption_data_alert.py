import csv
import io
import datetime
import logging

from customer_types import CustomerType
from customer_error_type import CustomerErrorType
from database_handler import DatabaseHandler
from sns_handler import SnsHandler
from sqs_handler import SqsHandler
from s3_handler import S3Handler

DYNAMO_DB_TABLE = 'customers'
FUNCTION_NAME   = 'NOT_RECEIVED_CONSUMPTION_DATA_ALERT'# TODO
DEFAULT_REGION  = "eu-central-1"

SOURCE_BUCKET = 'postgres-db-consumption-data-exports-bucket'
SNS_TOPIC_ARN = 'arn:aws:sns:eu-central-1:820242920924:admin_email_topic' #TODO os.getenv("SNS_TOPIC_ARN")
QUEUE_URL     = 'https://sqs.eu-central-1.amazonaws.com/820242920924/alerting_queue' #TODO

BILLING_METERING_COLUMN_NUMBER  = 1
AVERAGE_VOLTAGE_COLUMN_NUMBER   = 4
AVERAGE_FREQUENCY_COLUMN_NUMBER = 5
VOLTAGE_DROPS_COLUMN_NUMBER     = 6
DOWN_TIME_PERIOD_COLUMN_NUMBER  = 7

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(f"Lambda {FUNCTION_NAME} triggered.")

    try:
        consumption_data_alert = ConsumptionDataAlert()
        return consumption_data_alert.alert_customers_if_needed()
    except Exception as e:
        error_message = f"Error occurred in {FUNCTION_NAME} lambda: {e}"
        logger.error(error_message)
        raise e


class ConsumptionDataAlert:

    def __init__(self):
        self.database_handler = DatabaseHandler(DEFAULT_REGION)
        self.sns_handler      = SnsHandler()
        self.sqs_handler      = SqsHandler()
        self.s3_handler       = S3Handler()

    def alert_customers_if_needed(self):
        yesterday_date_str = self.get_yesterday_date()
        source_key = f'export-{yesterday_date_str}.csv'

        response = self.s3_handler.download_file_from_s3(SOURCE_BUCKET, source_key)
        csv_content = response['Body'].read().decode('utf-8')
        reader = csv.reader(io.StringIO(csv_content))

        next(reader)
        rows = list(reader)

        active_customers_data_map = self.database_handler.get_active_customers()

        self.alert_customers_who_not_submitted_data(rows, active_customers_data_map, yesterday_date_str)
        self.alert_customers_who_not_sent_network_parameters_data(rows, active_customers_data_map, yesterday_date_str)

        return {'statusCode': 200}


    def alert_customers_who_not_submitted_data(self, rows, active_customers_data_map, date_str):
        billing_metering_point_numbers_of_customers_who_submitted_data = set()
        for row in rows:
            billing_metering_point_number = row[BILLING_METERING_COLUMN_NUMBER]
            billing_metering_point_numbers_of_customers_who_submitted_data.add(billing_metering_point_number)

        customers_who_not_submitted_data = {key: value for key, value in active_customers_data_map.items()
                                            if key not in billing_metering_point_numbers_of_customers_who_submitted_data}

        if len(customers_who_not_submitted_data) == 0:
            logger.info(f"All active customers submitted data for date:{date_str}")
            return

        self.publish_sns_message(CustomerErrorType.MCD.value, customers_who_not_submitted_data, date_str)
        self.send_messages_to_sqs(CustomerErrorType.MCD.value, customers_who_not_submitted_data, date_str)

    def alert_customers_who_not_sent_network_parameters_data(self, rows, active_customers_data_map, date_str):
        customers_that_should_sent_parameters_data = {
            key: value for key, value in active_customers_data_map.items()
            if value["type"] in CustomerType.get_types_that_require_parameters()
        }

        customers_who_not_submitted_data_with_network_parameters = set()
        for row in rows:
            if (row[AVERAGE_VOLTAGE_COLUMN_NUMBER] == '' or row[AVERAGE_FREQUENCY_COLUMN_NUMBER] == ''
                    or row[VOLTAGE_DROPS_COLUMN_NUMBER] == '' or row[DOWN_TIME_PERIOD_COLUMN_NUMBER] == '') :
                customers_who_not_submitted_data_with_network_parameters.add(row[BILLING_METERING_COLUMN_NUMBER])

        customers_who_not_submitted_params_but_should = {key: value for key, value in customers_that_should_sent_parameters_data.items()
                                            if key in customers_who_not_submitted_data_with_network_parameters}

        if len(customers_who_not_submitted_params_but_should) == 0:
            logger.info(f"All customers who needed to send network parameters have sent them for date:{date_str}")
            return

        self.publish_sns_message(CustomerErrorType.MNP.value, customers_who_not_submitted_params_but_should, date_str)
        self.send_messages_to_sqs(CustomerErrorType.MNP.value, customers_who_not_submitted_params_but_should, date_str)

    def publish_sns_message(self, customer_error_type, customers, date):
        message = f"Billing Metering Point Numbers: {customers.keys()}"
        logger.info(message)
        sns_subject = f"Customers error:{customer_error_type} for date:{date}"
        self.sns_handler.publish_message(SNS_TOPIC_ARN, sns_subject, message)

    def send_messages_to_sqs(self, customer_error_type, customers, date):
        for key, value in customers.items():
            message_body = {
                "billing_metering_point_number": key,
                "attributes": value,
                "type": customer_error_type,
                "date": date
            }
            self.sqs_handler.send_message(QUEUE_URL, message_body)

    def get_yesterday_date(self):
        yesterday = datetime.datetime.utcnow() - datetime.timedelta(days=1)
        return yesterday.strftime('%Y-%m-%d')
