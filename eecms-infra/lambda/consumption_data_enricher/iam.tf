resource "aws_iam_role" "consumption_data_enricher" {
  name = "consumption_data_enricher"

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

resource "aws_iam_role_policy_attachment" "consumption_data_enricher_attach" {
  role       = aws_iam_role.consumption_data_enricher.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "consumption_data_enricher_basic_execution" {
  role = aws_iam_role.consumption_data_enricher.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  depends_on = [aws_iam_role.consumption_data_enricher]
}

//------------------------------------------------------
#Logging
resource "aws_iam_policy" "consumption_data_enricher_logging_policy" {
  name   = "consumption_data_enricher_logging_policy"
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

resource "aws_iam_role_policy_attachment" "consumption_data_enricher_logging_policy_attachment" {
  role = aws_iam_role.consumption_data_enricher.id
  policy_arn = aws_iam_policy.consumption_data_enricher_logging_policy.arn
}



//------------------------------------------------------
#DynamoDB
resource "aws_iam_policy" "consumption_data_enricher_dynamo_db_policy" {
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:Scan"]
      Effect   = "Allow"
      Resource = "arn:aws:dynamodb:*:*:table/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "consumption_data_enricher_dynamo_db_policy_attachment" {
  role = aws_iam_role.consumption_data_enricher.id
  policy_arn = aws_iam_policy.consumption_data_enricher_dynamo_db_policy.arn
}
//------------------------------------------------------
#S3
resource "aws_iam_policy" "consumption_data_enricher_s3_policy" {
  name        = "consumption_data_enricher_s3_policy"
  description = "Allow Lambda to write to S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::postgres-db-exports-bucket/*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::postgres-db-exports-bucket"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::enriched-consumption-data-bucket/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.consumption_data_enricher.name
  policy_arn = aws_iam_policy.consumption_data_enricher_s3_policy.arn
}


