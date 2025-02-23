resource "aws_lambda_function" "consumption_data_alert" {
  function_name    = "consumption_data_alert"
  role             = aws_iam_role.consumption_data_alert_role.arn
  runtime          = "python3.8"
  handler          = "consumption_data_alert.lambda_handler"
  source_code_hash = data.archive_file.consumption_data_alert_zip.output_base64sha256
  filename         = data.archive_file.consumption_data_alert_zip.output_path
  timeout          = 15

  environment {
    variables = {
      DYNAMO_DB_TABLE = "customers",#TODO
      FUNCTION_NAME   = "consumption_data_alert",
      DEFAULT_REGION  = "eu-central-1",
      SOURCE_BUCKET   = "postgres-db-consumption-data-exports-bucket",
      SNS_TOPIC_ARN   = "arn:aws:sns:eu-central-1:820242920924:admin_email_topic",
      QUEUE_URL       = "https://sqs.eu-central-1.amazonaws.com/820242920924/alerting_queue" #TODO

    }
  }
}

data "archive_file" "consumption_data_alert_zip" {
  type = "zip"
  output_path = "${path.module}/artifacts/consumption_data_alert_enricher.zip"
  source_dir = "${path.module}/source"
}