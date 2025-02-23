import logging
import sys

sys.path.append('../domain')
sys.path.append('../infrastructure')
sys.path.append('../util')

from domain.customer_error_type import CustomerErrorType
from domain.customer_type import CustomerType
from util.messaging_util import MessagingUtil

BILLING_METERING_COLUMN_NUMBER  = 1
AVERAGE_VOLTAGE_COLUMN_NUMBER   = 4
AVERAGE_FREQUENCY_COLUMN_NUMBER = 5
VOLTAGE_DROPS_COLUMN_NUMBER     = 6
DOWN_TIME_PERIOD_COLUMN_NUMBER  = 7

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class SubmittedNetworkParametersAlertService:

    def __init__(self):
        self.messaging_util = MessagingUtil()

    def alert_customers_who_not_sent_network_parameters_data(self, rows, active_customers_data_map, date_str):
        customer_error_type = CustomerErrorType.MNP.value
        logger.info(f"ALERT CHECK: {customer_error_type}")
        customers_that_should_sent_parameters_data = {
            key: value for key, value in active_customers_data_map.items()
            if value["type"] in CustomerType.get_types_that_require_parameters()
        }

        customers_who_not_submitted_data_with_network_parameters = set()
        for row in rows:
            if (row[AVERAGE_VOLTAGE_COLUMN_NUMBER] == '' or row[AVERAGE_FREQUENCY_COLUMN_NUMBER] == ''
                    or row[VOLTAGE_DROPS_COLUMN_NUMBER] == '' or row[DOWN_TIME_PERIOD_COLUMN_NUMBER] == '') :
                customers_who_not_submitted_data_with_network_parameters.add(int(row[BILLING_METERING_COLUMN_NUMBER]))

        customers_who_not_submitted_params_but_should = {key: value for key, value in customers_that_should_sent_parameters_data.items()
                                                         if key in customers_who_not_submitted_data_with_network_parameters}

        if len(customers_who_not_submitted_params_but_should) == 0:
            logger.info(f"All customers who needed to send network parameters have sent them for date:{date_str}")
            return

        self.messaging_util.publish_sns_message(customer_error_type, customers_who_not_submitted_params_but_should, date_str)
        self.messaging_util.send_messages_to_sqs(customer_error_type, customers_who_not_submitted_params_but_should, date_str)
