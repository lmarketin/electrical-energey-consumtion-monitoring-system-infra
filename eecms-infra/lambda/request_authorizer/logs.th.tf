resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/request_authorizer"
  retention_in_days = 5
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "LambdaLoggingPolicy"
  description = "Allows Lambda to write logs to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.lambda_logs.arn}:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attach" {
  role       = aws_iam_role.request_authorizer.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}