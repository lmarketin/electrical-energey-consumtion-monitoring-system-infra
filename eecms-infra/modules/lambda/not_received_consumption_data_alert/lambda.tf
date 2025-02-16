resource "aws_lambda_function" "not_received_consumption_data_alert" {
  function_name    = "not_received_consumption_data_alert"
  role             = aws_iam_role.not_received_consumption_data_alert.arn
  runtime          = "python3.8"
  handler          = "not_received_consumption_data_alert.lambda_handler"
  source_code_hash = data.archive_file.not_received_consumption_data_alert_zip.output_base64sha256
  filename         = data.archive_file.not_received_consumption_data_alert_zip.output_path
  timeout          = 15
}

data "archive_file" "not_received_consumption_data_alert_zip" {
  type = "zip"
  output_path = "${path.module}/artifacts/not_received_consumption_data_alert_enricher.zip"
  source_dir = "${path.module}/source"
}