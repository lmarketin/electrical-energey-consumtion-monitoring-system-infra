output "alb_sg_id" {
  value = aws_security_group.lb_sg.id
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.lb_target_group.arn
}

output "lb_listener" {
  value = aws_lb_listener.lb_listener
}

output "lb_listener_arn" {
  value = aws_lb_listener.lb_listener.arn
}