import boto3
import csv
import io
import datetime
import logging
import json

from database_handler import DatabaseHandler

DYNAMO_DB_TABLE = 'customers'
FUNCTION_NAME   = 'NOT_RECEIVED_CONSUMPTION_DATA_ALERT'# TODO
DEFAULT_REGION  = "eu-central-1"

SOURCE_BUCKET = 'postgres-db-exports-bucket'
SNS_TOPIC_ARN = 'arn:aws:sns:eu-central-1:820242920924:admin_email_topic' #TODO os.getenv("SNS_TOPIC_ARN")
QUEUE_URL     = 'https://sqs.eu-central-1.amazonaws.com/820242920924/alerting_queue' #TODO

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(f"Lambda {FUNCTION_NAME} triggered.")

    try:
        not_received_consumption_data_alert = NotReceivedConsumptionDataAlert()
        return not_received_consumption_data_alert.alert_customers_if_needed()
    except Exception as e:
        error_message = f"Error occurred in {FUNCTION_NAME} lambda: {e}"
        logger.error(error_message)
        raise e


class NotReceivedConsumptionDataAlert:

    def __init__(self):
        self.database_handler = DatabaseHandler(DEFAULT_REGION)
        self.s3  = boto3.client('s3')
        self.sns = boto3.client("sns")
        self.sqs = boto3.client("sqs")

    def alert_customers_if_needed(self):
        date_str = self.get_yesterday_date()
        source_key = f'export-{date_str}.csv'

        try:
            logger.info(f"Downloading extracted report. Bucket:{SOURCE_BUCKET}, Key:{source_key}")
            response = self.s3.get_object(Bucket=SOURCE_BUCKET, Key=source_key)
            logger.info(f"Downloaded extracted report for date:{date_str}")
            csv_content = response['Body'].read().decode('utf-8')

            reader = csv.reader(io.StringIO(csv_content))
            rows = list(reader)

            logger.info(f"Fetching customers data from DynamoDB customers table")
            customers_data_map = self.database_handler.get_all_customers()
            logger.info(f"Fetched customers data from DynamoDB customers table, dynamo_data_map:{customers_data_map}")

            customers_emails_map = {api_key: customer["email"] for api_key, customer in customers_data_map.items()}

            customers_who_submitted_data = set()
            for row in rows:
                primary_key_value = row[1]
                customers_who_submitted_data.add(primary_key_value)

            emails_customers_who_not_submitted_data = [
                email for customer, email in customers_emails_map.items() if customer not in customers_who_submitted_data
            ]
            message = f"Emails of customers who not submitted data:{emails_customers_who_not_submitted_data}."
            logger.info(message)

            self.sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=message,
                Subject="Customers who not submitted data",
            )

            #TODO
            for email in emails_customers_who_not_submitted_data:
                response = self.sqs.send_message(
                    QueueUrl=QUEUE_URL,
                    MessageBody=json.dumps({"email": email})
                )


            return {'statusCode': 200}
        except Exception as e:
            return {'statusCode': 500, 'body': str(e)}

    def get_yesterday_date(self):
        yesterday = datetime.datetime.utcnow() - datetime.timedelta(days=1)
        return yesterday.strftime('%Y-%m-%d')
