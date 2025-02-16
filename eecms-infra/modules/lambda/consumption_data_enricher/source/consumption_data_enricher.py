import boto3
import csv
import io
import datetime
import logging

from database_handler import DatabaseHandler

DYNAMO_DB_TABLE = 'customers'
FUNCTION_NAME   = 'CONSUMPTION_DATA_ENRICHER'# TODO
DEFAULT_REGION = "eu-central-1"

SOURCE_BUCKET = 'postgres-db-consumption-data-exports-bucket'
DESTINATION_BUCKET = 'enriched-consumption-data-bucket'

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(f"Lambda triggered.")

    try:
        consumption_data_enricher = ConsumptionDatEnricher()
        return consumption_data_enricher.enrich_consumption_data()
    except Exception as e:
        error_message = f"Error occurred in {FUNCTION_NAME} lambda: {e}"
        logger.error(error_message)
        raise e


class ConsumptionDatEnricher:

    def __init__(self):
        self.database_handler = DatabaseHandler(DEFAULT_REGION)
        self.s3 = boto3.client('s3')

    def enrich_consumption_data(self):
        date_str = self.get_yesterday_date()
        source_key = f'export-{date_str}.csv'
        destination_key = f'enriched_consumption_data_{date_str}.csv'

        try:
            logger.info(f"Downloading extracted report. Bucket:{SOURCE_BUCKET}, Key:{source_key}")
            response = self.s3.get_object(Bucket=SOURCE_BUCKET, Key=source_key)
            logger.info(f"Downloaded extracted report for date:{date_str}. Report modified at:{response['LastModified']}.")
            csv_content = response['Body'].read().decode('utf-8')

            reader = csv.reader(io.StringIO(csv_content))
            rows = list(reader)

            header = rows[0] + ['Name', 'County', 'Address', 'Type']
            updated_rows = [header]

            logger.info(f"Fetching customers data from DynamoDB customers table.")
            dynamo_data_map = self.database_handler.get_all_customers()
            logger.info(f"Fetched customers data from DynamoDB customers table.")

            for row in rows[1:]:
                billing_metering_point_number = row[1]
                logger.info(f"==== billing_metering_point_number:{billing_metering_point_number}")
                dynamo_data = dynamo_data_map.get(int(billing_metering_point_number), {})
                logger.info(f"==== dynamo_data:{dynamo_data}")
                customer_type = dynamo_data.get('type', 'default_value')
                should_send_network_quality_parameters = dynamo_data.get('should_send_network_quality_parameters', 'default_value')
                active = dynamo_data.get('active', 'default_value')
                name = dynamo_data.get('name', 'default_value')
                county = dynamo_data.get('county', 'default_value')
                city = dynamo_data.get('active', 'default_value')
                address = dynamo_data.get('address', 'default_value')
                email = dynamo_data.get('email', 'default_value')
                updated_rows.append(row + [customer_type, should_send_network_quality_parameters, active, name, county,
                                           city, address, email])

            output = io.StringIO()
            writer = csv.writer(output)
            writer.writerows(updated_rows)

            self.s3.put_object(
                Bucket=DESTINATION_BUCKET,
                Key=destination_key,
                Body=output.getvalue(),
                ContentType="text/csv"
            )

            return {'statusCode': 200, 'body': f'File {destination_key} created successfully.'}
        except Exception as e:
            return {'statusCode': 500, 'body': str(e)}

    def get_yesterday_date(self):
        yesterday = datetime.datetime.utcnow() - datetime.timedelta(days=1)
        return yesterday.strftime('%Y-%m-%d')