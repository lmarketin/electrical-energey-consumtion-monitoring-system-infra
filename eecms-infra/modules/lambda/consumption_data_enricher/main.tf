resource "aws_lambda_function" "consumption_data_enricher" {
  function_name    = "consumption_data_enricher"
  role            = aws_iam_role.consumption_data_enricher_role.arn
  runtime         = "python3.8"
  handler         = "consumption_data_enricher.lambda_handler"
  source_code_hash = data.archive_file.consumption_data_enricher_zip.output_base64sha256
  filename        = data.archive_file.consumption_data_enricher_zip.output_path
  timeout         = 15

  environment {
    variables = {
      DYNAMO_DB_TABLE = var.dynamodb_table
      FUNCTION_NAME   = "consumption_data_enricher"
      DEFAULT_REGION  = var.region
      SOURCE_BUCKET   = var.source_bucket
      DESTINATION_BUCKET = var.destination_bucket
    }
  }
}

data "archive_file" "consumption_data_enricher_zip" {
  type = "zip"
  output_path = "${path.module}/artifacts/consumption_data_enricher.zip"
  source_dir = "${path.module}/source"
}