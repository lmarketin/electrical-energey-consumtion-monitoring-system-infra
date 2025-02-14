module "postgres_db_exporter" {
  source = "./lambda/postgres_db_exporter"
}

module "consumption_data_enricher" {
  source = "./lambda/consumption_data_enricher"
}

module "not_received_consumption_data_alert" {
  source = "./lambda/not_received_consumption_data_alert"
}


resource "aws_iam_role" "ecsTaskExecutionRole" {
  name                  = "test-app-ecsTaskExecutionRole"
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions               = ["sts:AssumeRole"]

    principals {
      type                = "Service"
      identifiers         = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role                  = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn            = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecsTaskRole" {
  name                  = "ecsTaskRole"
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskRole_policy" {
  role                  = aws_iam_role.ecsTaskRole.name
  policy_arn            = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs-task-policy"
  description = "Allow ECS task to write to CloudWatch logs"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.ecs_log_group.arn}:*"
      }
    ]
  })
}
#-------------------------------------------------------
#Cloudwatch/EventBridge
#-------------------------------------------------------

data "aws_iam_policy_document" "cloudwatch_trigger_step_function_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "cloudwatch_trigger_step_function_role" {
  name               = "cloudwatch_trigger_step_function_role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_trigger_step_function_document.json
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "cloudwatch_trigger_step_function_policy" {
  name = "cloudwatch_trigger_step_function_policy"
  role = aws_iam_role.cloudwatch_trigger_step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "states:StartExecution"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:states:${var.region}:${data.aws_caller_identity.current.account_id}:stateMachine:consumption_data_pipeline"
      }
    ]
  })
}

#-------------------------------------------------------
#Step function
#-------------------------------------------------------
resource "aws_iam_role" "step_function_role" {
  name = "step_function_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_policy" {
  name        = "step_function_policy"
  description = "Policy for Step Function to invoke Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          module.postgres_db_exporter.postgres_db_exporter_lambda_arn,
          module.consumption_data_enricher.consumption_data_enricher_lambda_arn,
          module.not_received_consumption_data_alert.not_received_consumption_data_alert_lambda_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_policy_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}


#-------------------------------------------------------
