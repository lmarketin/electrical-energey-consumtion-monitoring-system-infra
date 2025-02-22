import boto3
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class SqsHandler:

    def __init__(self):
        self.sqs = boto3.client("sqs")

    def send_message(self, queue_url, message_body):
        response = self.sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(message_body)
        )

        logger.info(f"SQS message sent to queue: {queue_url}"
                    f"MessageId: {response['MessageId']}, MessageBody: {message_body}")
