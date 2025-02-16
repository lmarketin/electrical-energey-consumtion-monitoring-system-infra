output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "lb_listener" {
  value = aws_lb_listener.listener
}

output "lb_listener_arn" {
  value = aws_lb_listener.listener.arn
}