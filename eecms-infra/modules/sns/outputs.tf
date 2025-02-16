output "sqs_topic_email_arn" {
  value = aws_sns_topic.admin_email_topic.arn
}