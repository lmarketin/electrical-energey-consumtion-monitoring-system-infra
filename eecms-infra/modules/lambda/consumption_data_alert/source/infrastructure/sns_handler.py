import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class SnsHandler:

    def __init__(self):
        self.sns = boto3.client("sns")

    def publish_message(self, sns_topic_arn, subject, message):
        response = self.sns.publish(
            TopicArn=sns_topic_arn,
            Subject=subject,
            Message=message
        )

        logger.info(f"SNS message sent to topic: {sns_topic_arn}"
                    f"MessageId: {response['MessageId']}, Subject:{subject} , Message: {message}")