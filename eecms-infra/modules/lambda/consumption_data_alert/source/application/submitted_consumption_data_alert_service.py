import logging
import sys

sys.path.append('../domain')
sys.path.append('../infrastructure')
sys.path.append('../util')

from domain.customer_error_type import CustomerErrorType
from util.messaging_util import MessagingUtil

BILLING_METERING_COLUMN_NUMBER  = 1

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class SubmittedConsumptionDataAlertService:

    def __init__(self):
        self.messaging_util = MessagingUtil()

    def alert_customers_who_not_submitted_data(self, rows, active_customers_data_map, date_str):
        customer_error_type = CustomerErrorType.MCD.value
        logger.info(f"ALERT CHECK: {customer_error_type}")
        billing_metering_point_numbers_of_customers_who_submitted_data = set()
        for row in rows:
            billing_metering_point_number = int(row[BILLING_METERING_COLUMN_NUMBER])
            billing_metering_point_numbers_of_customers_who_submitted_data.add(billing_metering_point_number)

        customers_who_not_submitted_data = {key: value for key, value in active_customers_data_map.items()
                                            if key not in billing_metering_point_numbers_of_customers_who_submitted_data}

        if len(customers_who_not_submitted_data) == 0:
            logger.info(f"All active customers submitted data for date:{date_str}")
            return

        self.messaging_util.publish_sns_message(customer_error_type, customers_who_not_submitted_data, date_str)
        self.messaging_util.send_messages_to_sqs(customer_error_type, customers_who_not_submitted_data, date_str)
