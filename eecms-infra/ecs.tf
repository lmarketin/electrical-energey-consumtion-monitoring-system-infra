resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/ecs_cluster"
  retention_in_days = 5
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "ecs-task"
  container_definitions = jsonencode([
    {
      name        = "app-container"
      image       = "${aws_ecr_repository.ecr_repo.repository_url}:latest"
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
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
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
  execution_role_arn                  = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn                       = aws_iam_role.ecsTaskRole.arn
}

resource "aws_ecs_service" "ecs_service" {
  name                              = "ecs-service"
  cluster                           = aws_ecs_cluster.ecs_cluster.arn
  task_definition                   = aws_ecs_task_definition.task_definition.arn
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  desired_count                     = 2
  health_check_grace_period_seconds = 12000

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id , aws_subnet.private_subnet_2.id]
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id, aws_security_group.alb_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "app-container"
    container_port   = var.container_port
  }
  depends_on = [aws_lb_listener.listener]
}
