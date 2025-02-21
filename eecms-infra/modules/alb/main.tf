resource "aws_alb" "lb" {
  name                      = "lb"
  internal                  = false
  load_balancer_type        = "application"
  subnets                   = [var.public_subnet_1_id, var.public_subnet_2_id]//-
  security_groups           = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "lb_target_group" {
  name                      = "targetgroup"
  port                      = var.container_port
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = var.vpc_id
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn         = aws_alb.lb.arn
  port                      = "80"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.lb_target_group.arn
  }
}

# ------------------------------------------------------------------------------
# Security Group and Rules for alb
# ------------------------------------------------------------------------------
resource "aws_security_group" "lb_sg" {
  name                        = "lb_sg"
  vpc_id                      = var.vpc_id
  revoke_rules_on_delete      = true
}

resource "aws_security_group_rule" "lb_http_ingress" {
  type                        = "ingress"
  from_port                   = 80
  to_port                     = 80
  protocol                    = "TCP"
  description                 = "Allow http inbound traffic from internet"
  security_group_id           = aws_security_group.lb_sg.id
  cidr_blocks                 = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "alb_https_ingress" {
  type                        = "ingress"
  from_port                   = 443
  to_port                     = 443
  protocol                    = "TCP"
  description                 = "Allow https inbound traffic from internet"
  security_group_id           = aws_security_group.lb_sg.id
  cidr_blocks                 = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress" {
  type                        = "egress"
  from_port                   = 0
  to_port                     = 0
  protocol                    = "-1"
  description                 = "Allow outbound traffic from alb"
  security_group_id           = aws_security_group.lb_sg.id
  cidr_blocks                 = ["0.0.0.0/0"]
}
