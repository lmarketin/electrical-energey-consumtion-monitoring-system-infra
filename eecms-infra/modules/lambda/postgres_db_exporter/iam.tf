resource "aws_iam_role" "postgres_db_exporter" {
  name = "postgres_db_exporter"

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

resource "aws_iam_role_policy_attachment" "postgres_db-attach" {
  role       = aws_iam_role.postgres_db_exporter.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "postgres_db_exporter_basic_execution" {
  role = aws_iam_role.postgres_db_exporter.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  depends_on = [aws_iam_role.postgres_db_exporter]
}

resource "aws_iam_policy" "postgres_db_exporter_logging_policy" {
  name   = "postgres_db_exporter_logging_policy"
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

resource "aws_iam_role_policy_attachment" "postgres_db_exporter_logging_policy_attachment" {
  role = aws_iam_role.postgres_db_exporter.id
  policy_arn = aws_iam_policy.postgres_db_exporter_logging_policy.arn
}



//------------------------------------------------------

resource "aws_iam_role_policy" "postgres_db_exporter_policy" {
  name = "LambdaRDSPolicy"
  role = aws_iam_role.postgres_db_exporter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

#S3
resource "aws_iam_policy" "postgres_db_exporter_s3_policy" {
  name        = "postgres_db_exporter_s3_policy"
  description = "Allow Lambda to write to S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::postgres-db-consumption-data-exports-bucket/*"
        Effect   = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.postgres_db_exporter_s3_policy.arn
  role       = aws_iam_role.postgres_db_exporter.name
}


