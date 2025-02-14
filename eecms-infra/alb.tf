resource "aws_alb" "alb" {
  name                      = "alb"
  internal                  = false
  load_balancer_type        = "application"
  subnets                   = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]//-
  security_groups           = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "target_group" {
  name                      = "targetgroup"
  port                      = var.container_port
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = aws_vpc.vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn         = aws_alb.alb.arn
  port                      = "80"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.target_group.arn
  }
}