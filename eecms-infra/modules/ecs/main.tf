resource "aws_ecs_cluster" "eecss_cluster" {
  name = "eecss_cluster"
}

resource "aws_ecs_task_definition" "eecss_task_definition" {
  family                = "eecss_task_definition"
  container_definitions = jsonencode([
    {
      name        = "app-container"
      image       = "${var.eecss_repo_url}:latest"
      essential   = true
      networkMode = "awsvpc"
      entryPoint  = []

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.eecss_cluster_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs-service-"
        }
      }

      environment = [
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:postgresql://pgsql.cr66uewyk9gp.eu-central-1.rds.amazonaws.com:5432/pgsql"
        },

        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = var.db_username
        },
        {
          name  = "SPRING_DATASOURCE_PASSWORD"
          value = var.db_password
        }
      ]

      /*healthCheck = {
        command     = [ "CMD-SHELL", "curl -f http://localhost:8080/actuator/health || exit 1" ]
        interval    = 30
        timeout     = 5
        startPeriod = 120
        retries     = 3
      }*/
    }
  ])
  requires_compatibilities            = ["FARGATE"]
  network_mode                        = "awsvpc"
  cpu                                 = "256"
  memory                              = "512"
  execution_role_arn                  = aws_iam_role.eecss_ecs_task_execution_role.arn
  //task_role_arn                       = aws_iam_role.eecss_ecs_dynamodb_role.arn
}

resource "aws_ecs_service" "eecss_service" {
  name                              = "eecss_service"
  cluster                           = aws_ecs_cluster.eecss_cluster.arn
  task_definition                   = aws_ecs_task_definition.eecss_task_definition.arn
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  desired_count                     = 2
  health_check_grace_period_seconds = 12000

  network_configuration {
    subnets          = [var.private_subnet_1_id, var.private_subnet_2_id ]
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id, var.alb_sg_id]
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "app-container"
    container_port   = var.container_port
  }
  depends_on = [var.lb_listener]
}


# ------------------------------------------------------------------------------
# Security Group and Rules for ECS app
# ------------------------------------------------------------------------------
resource "aws_security_group" "ecs_sg" {
  vpc_id                      = var.vpc_id
  name                        = "ecs_sg"
  description                 = "Security group for ecs app"
  revoke_rules_on_delete      = true
}

resource "aws_security_group_rule" "ecs_lb_ingress" {
  type                        = "ingress"
  from_port                   = 0
  to_port                     = 0
  protocol                    = "-1"
  description                 = "Allow inbound traffic from LB"
  security_group_id           = aws_security_group.ecs_sg.id
  source_security_group_id    = var.alb_sg_id
}

resource "aws_security_group_rule" "ecs_all_egress" {
  type                        = "egress"
  from_port                   = 0
  to_port                     = 0
  protocol                    = "-1"
  description                 = "Allow outbound traffic from ECS"
  security_group_id           = aws_security_group.ecs_sg.id
  cidr_blocks                 = ["0.0.0.0/0"]
}
