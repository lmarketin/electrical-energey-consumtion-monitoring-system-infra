import os
import psycopg2
import csv
import boto3
from io import StringIO
from datetime import datetime, timedelta

S3_BUCKET = "postgres-db-consumption-data-exports-bucket"

s3_client = boto3.client('s3')

def lambda_handler(event, context):

    connection = None
    try:
        connection = psycopg2.connect(
            host="pgsql.cr66uewyk9gp.eu-central-1.rds.amazonaws.com",
            database=os.environ['DB_NAME'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD']
        )
        cursor = connection.cursor()

        query = "SELECT * FROM energy_consumption;"
        cursor.execute(query)

        rows = cursor.fetchall()

        output = StringIO()
        csv_writer = csv.writer(output)

        column_names = [desc[0] for desc in cursor.description]
        csv_writer.writerow(column_names)

        for row in rows:
            csv_writer.writerow(row)

        output.seek(0)

        current_date = datetime.now().strftime("%Y-%m-%d")
        yesterday_date = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
        export_name = f"export-{yesterday_date}"

        s3_key = f"{export_name}.csv"
        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=s3_key,
            Body=output.getvalue(),
            ContentType="text/csv"
        )

        cursor.close()
        connection.close()

        return {
            'statusCode': 200,
            'body': f"Data exported successfully to S3://{S3_BUCKET}/{s3_key}"
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": str(e)
        }
    finally:
        if connection:
            cursor.close()
            connection.close()