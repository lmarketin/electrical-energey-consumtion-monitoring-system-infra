import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

QUEUE_URL = os.getenv('QUEUE_URL')


class SqsHandler:

    def __init__(self):
        self.sqs = boto3.client("sqs")

    def send_message(self, message_body):
        response = self.sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message_body)
        )

        logger.info(f"SQS message sent to queue: {QUEUE_URL}"
                    f"MessageId: {response['MessageId']}, MessageBody: {message_body}")
