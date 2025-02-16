resource "aws_iam_role" "request_authorizer" {
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


resource "aws_iam_role_policy_attachment" "request_authorizer_basic_execution" {
  role = aws_iam_role.request_authorizer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  depends_on = [aws_iam_role.request_authorizer]
}

resource "aws_iam_role_policy_attachment" "request_authorizer" {
  role = aws_iam_role.request_authorizer.name
  policy_arn = aws_iam_policy.request_authorizer.arn
  depends_on = [aws_iam_role.request_authorizer, aws_iam_policy.request_authorizer]
}

resource "aws_iam_policy" "request_authorizer" {
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:GetItem"]
      Effect   = "Allow"
      Resource = "arn:aws:dynamodb:*:*:table/*"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "request_authorizer_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.request_authorizer.name
}

resource "aws_lambda_permission" "request_authorizer_api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.request_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
}






resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
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

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.request_authorizer.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}
