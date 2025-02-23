import csv
import io
import datetime
import logging
import sys
import os

sys.path.append('../application')
sys.path.append('../domain')
sys.path.append('../infrastructure')

from application.submitted_consumption_data_alert_service import SubmittedConsumptionDataAlertService
from application.submitted_network_parameters_alert_service import SubmittedNetworkParametersAlertService
from infrastructure.s3_handler import S3Handler
from infrastructure.database_handler import DatabaseHandler

FUNCTION_NAME   = os.getenv('FUNCTION_NAME')
DEFAULT_REGION  = os.getenv('DEFAULT_REGION')

SOURCE_BUCKET = os.getenv('SOURCE_BUCKET')

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
        self.submitted_data_consumption_alert_service = SubmittedConsumptionDataAlertService()
        self.submitted_network_parameters_alert_service = SubmittedNetworkParametersAlertService()
        self.s3_handler = S3Handler()
        self.database_handler = DatabaseHandler(DEFAULT_REGION)

    def alert_customers_if_needed(self):
        yesterday_date_str = self.get_yesterday_date()
        source_key = f'export-{yesterday_date_str}.csv'

        response = self.s3_handler.download_file_from_s3(SOURCE_BUCKET, source_key)
        csv_content = response['Body'].read().decode('utf-8')
        reader = csv.reader(io.StringIO(csv_content))

        next(reader)
        rows = list(reader)

        active_customers_data_map = self.database_handler.get_active_customers()

        self.submitted_data_consumption_alert_service.alert_customers_who_not_submitted_data(rows, active_customers_data_map, yesterday_date_str)
        self.submitted_network_parameters_alert_service.alert_customers_who_not_sent_network_parameters_data(rows, active_customers_data_map, yesterday_date_str)

        return {'statusCode': 200}

    def get_yesterday_date(self):
        yesterday = datetime.datetime.utcnow() - datetime.timedelta(days=1)
        return yesterday.strftime('%Y-%m-%d')
