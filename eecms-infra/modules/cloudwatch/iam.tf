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