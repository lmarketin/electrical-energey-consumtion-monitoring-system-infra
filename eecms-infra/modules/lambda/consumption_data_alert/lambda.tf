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
      DYNAMO_DB_TABLE = var.dynamodb_table
      FUNCTION_NAME   = "consumption_data_alert"
      DEFAULT_REGION  = var.region
      SOURCE_BUCKET   = var.source_bucket
      SNS_TOPIC_ARN   = var.sns_topic_arn
      QUEUE_URL       = var.queue_url
    }
  }
}

data "archive_file" "consumption_data_alert_zip" {
  type = "zip"
  output_path = "${path.module}/artifacts/consumption_data_alert_enricher.zip"
  source_dir = "${path.module}/source"
}