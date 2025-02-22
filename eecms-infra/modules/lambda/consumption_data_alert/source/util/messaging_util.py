import sys

sys.path.append('../infrastructure')

from infrastructure.sns_handler import SnsHandler
from infrastructure.sqs_handler import SqsHandler

class MessagingUtil:

    def __init__(self):
        self.sns_handler = SnsHandler()
        self.sqs_handler = SqsHandler()

    def publish_sns_message(self, sns_topic_arn, customer_error_type, customers, date):
        message = f"Billing Metering Point Numbers:  {', '.join(map(str, customers.keys()))}"
        sns_subject = f"Customers error:{customer_error_type} for date:{date}"
        self.sns_handler.publish_message(sns_topic_arn, sns_subject, message)

    def send_messages_to_sqs(self, queue_url, customer_error_type, customers, date):
        for key, value in customers.items():
            message_body = {
                "billing_metering_point_number": key,
                "attributes": value,
                "type": customer_error_type,
                "date": date
            }
            self.sqs_handler.send_message(queue_url, message_body)
