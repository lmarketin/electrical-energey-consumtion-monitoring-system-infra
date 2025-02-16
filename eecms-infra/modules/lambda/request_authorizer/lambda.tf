resource "aws_lambda_function" "request_authorizer" {
  function_name    = "request_authorizer"
  role            = aws_iam_role.request_authorizer.arn
  runtime         = "python3.8"
  handler         = "request_authorizer.lambda_handler"
  source_code_hash = data.archive_file.request_authorizer_zip.output_base64sha256
  filename        = data.archive_file.request_authorizer_zip.output_path
}

data "archive_file" "request_authorizer_zip" {
  type = "zip"
  output_path = "${path.module}/artifacts/request_authorizer.zip"
  source_dir = "${path.module}/source"
}


