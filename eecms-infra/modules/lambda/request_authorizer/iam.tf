resource "aws_iam_role" "request_authorizer_role" {
  name = "request_authorizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "request_authorizer_basic_execution_role_policy_attachment" {
  role = aws_iam_role.request_authorizer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  depends_on = [aws_iam_role.request_authorizer_role]
}

resource "aws_iam_policy" "request_authorizer_dynamodb_policy" {
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:GetItem"]
      Effect   = "Allow"
      Resource = "arn:aws:dynamodb:*:*:table/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "request_authorizer_dynamodb_role_policy_attachment" {
  role = aws_iam_role.request_authorizer_role.name
  policy_arn = aws_iam_policy.request_authorizer_dynamodb_policy.arn
  depends_on = [aws_iam_role.request_authorizer_role, aws_iam_policy.request_authorizer_dynamodb_policy]
}

resource "aws_lambda_permission" "request_authorizer_api_gateway_invoke_lambda_permission" {
  statement_id  = "request_authorizer_api_gateway_invoke_lambda_permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.request_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_policy" "request_authorizer_logging_policy" {
  name   = "request_authorizer_logging_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "request_authorizer_logging_role_policy_attachment" {
  role = aws_iam_role.request_authorizer_role.id
  policy_arn = aws_iam_policy.request_authorizer_logging_policy.arn
}
