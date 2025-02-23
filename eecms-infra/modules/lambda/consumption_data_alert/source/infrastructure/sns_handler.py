import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')


class SnsHandler:

    def __init__(self):
        self.sns = boto3.client("sns")

    def publish_message(self, subject, message):
        response = self.sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=subject,
            Message=message
        )

        logger.info(f"SNS message sent to topic: {SNS_TOPIC_ARN}"
                    f"MessageId: {response['MessageId']}, Subject:{subject} , Message: {message}")