output "sqs_alerting_queue_arn" {
  value = aws_sqs_queue.alerting_queue.arn
}

output "sqs_alerting_queue_name" {
  value = aws_sqs_queue.alerting_queue.name
}