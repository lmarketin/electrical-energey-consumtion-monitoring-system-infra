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