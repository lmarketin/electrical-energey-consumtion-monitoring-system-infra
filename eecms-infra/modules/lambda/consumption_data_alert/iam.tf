resource "aws_iam_role" "consumption_data_alert_role" {
  name = "consumption_data_alert_role"

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

resource "aws_iam_role_policy_attachment" "consumption_data_alert_vpc_role_policy_attachment" {
  role       = aws_iam_role.consumption_data_alert_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "consumption_data_alert_basic_execution_role_policy_attachment" {
  role = aws_iam_role.consumption_data_alert_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  depends_on = [aws_iam_role.consumption_data_alert_role]
}

#Logging
resource "aws_iam_policy" "consumption_data_alert_logging_policy" {
  name   = "not_received_consumption_data_alert_logging_policy"
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

resource "aws_iam_role_policy_attachment" "not_received_consumption_data_alert_logging_policy_attachment" {
  role = aws_iam_role.consumption_data_alert_role.id
  policy_arn = aws_iam_policy.consumption_data_alert_logging_policy.arn
}

#DynamoDB
resource "aws_iam_policy" "consumption_data_alert_dynamo_db_policy" {
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:Scan"]
      Effect   = "Allow"
      Resource = "arn:aws:dynamodb:*:*:table/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "not_received_consumption_data_alert_dynamo_db_policy_attachment" {
  role = aws_iam_role.consumption_data_alert_role.id
  policy_arn = aws_iam_policy.consumption_data_alert_dynamo_db_policy.arn
}

#S3
resource "aws_iam_policy" "consumption_data_alert_s3_policy" {
  name        = "consumption_data_alert_s3_policy"
  description = ""
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::postgres-db-consumption-data-exports-bucket/*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::postgres-db-consumption-data-exports-bucket"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "not_received_consumption_data_alert_s3_policy_attachment" {
  role       = aws_iam_role.consumption_data_alert_role.name
  policy_arn = aws_iam_policy.consumption_data_alert_s3_policy.arn
}

#SNS
resource "aws_iam_policy" "consumption_data_alert_sns_policy" {
  name        = "not_received_consumption_data_alert_sns_policy"
  description = ""
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_email_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "not_received_consumption_data_alert_sns_policy_attachment" {
  role       = aws_iam_role.consumption_data_alert_role.name
  policy_arn = aws_iam_policy.consumption_data_alert_sns_policy.arn
}

#SQS
resource "aws_iam_policy" "consumption_data_alert_sqs_policy" {
  name        = "consumption_data_alert_sqs_policy"
  description = "Allows Lambda to send messages to SQS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sqs:SendMessage"
      Resource = var.sqs_alerting_queue_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "not_received_consumption_data_alert_sqs_attach" {
  role       = aws_iam_role.consumption_data_alert_role.name
  policy_arn = aws_iam_policy.consumption_data_alert_sqs_policy.arn
}
