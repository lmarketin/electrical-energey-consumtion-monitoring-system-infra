resource "aws_iam_role" "api_gw_logging_role" {
  name = "api_gw_logging_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "api_gw_logging_policy" {
  name        = "api_gw_logging_policy"
  description = "Policy to allow API Gateway to write logs to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.api_gateway.arn}:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_logging_attach" {
  role       = aws_iam_role.api_gw_logging_role.name
  policy_arn = aws_iam_policy.api_gw_logging_policy.arn
}
