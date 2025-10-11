resource "aws_ecs_cluster" "eecms_cluster" {
  name = "eecms_cluster"
}

resource "aws_ecs_task_definition" "eecms_task_definition" {
  family                = "eecms_task_definition"
  container_definitions = jsonencode([
    {
      name        = "app-container"
      image       = "${var.eecms_repo_url}:latest"
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
          "awslogs-group"         = aws_cloudwatch_log_group.eecms_cluster_log_group.name
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
  execution_role_arn                  = aws_iam_role.eecms_ecs_task_execution_role.arn
}

resource "aws_ecs_service" "eecms_service" {
  name                              = "eecms_service"
  cluster                           = aws_ecs_cluster.eecms_cluster.arn
  task_definition                   = aws_ecs_task_definition.eecms_task_definition.arn
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  desired_count                     = 1
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

resource "aws_appautoscaling_target" "ecs_autoscaling" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.eecms_cluster.name}/${aws_ecs_service.eecms_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    null_resource.aws_ecs_cluster_exists,
    null_resource.aws_ecs_service_exists
  ]
}

resource "aws_appautoscaling_policy" "ecs_autoscaling" {
  name               = "ecs_autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_autoscaling.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_autoscaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_autoscaling.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 75
    scale_in_cooldown  = 120
    scale_out_cooldown = 60
  }
}

resource "null_resource" "aws_ecs_cluster_exists" {
  triggers = {
    aws_ecs_cluster_exists_arn = aws_ecs_cluster.eecms_cluster.arn
  }
}

resource "null_resource" "aws_ecs_service_exists" {
  triggers = {
    aws_ecs_service_exists_id = aws_ecs_service.eecms_service.id
  }
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
