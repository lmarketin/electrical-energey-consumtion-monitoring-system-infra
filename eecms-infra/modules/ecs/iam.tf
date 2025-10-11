resource "aws_iam_role" "eecms_ecs_task_execution_role" {
  name                  = "eecms_ecs_task_execution_role"
  assume_role_policy    = data.aws_iam_policy_document.eecms_ecs_policy_document.json
}

data "aws_iam_policy_document" "eecms_ecs_policy_document" {
  statement {
    actions               = ["sts:AssumeRole"]

    principals {
      type                = "Service"
      identifiers         = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eecms_ecs_task_execution_role_policy_attachment" {
  role                  = aws_iam_role.eecms_ecs_task_execution_role.name
  policy_arn            = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/*resource "aws_iam_role" "eecms_ecs_dynamodb_role" {
  name                  = "eecms_ecs_dynamodb_role"
  assume_role_policy    = data.aws_iam_policy_document.eecms_ecs_policy_document.json
}

resource "aws_iam_role_policy_attachment" "eecms_ecs_dynamodb_role_policy_attachment" {
  role                  = aws_iam_role.eecms_ecs_dynamodb_role.name
  policy_arn            = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}*/

resource "aws_iam_policy" "eecms_ecs_logs_policy" {
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
        Resource = "${aws_cloudwatch_log_group.eecms_cluster_log_group.arn}:*"
      }
    ]
  })
}