resource "aws_sqs_queue" "alerting_queue" {
  name                      = "alerting_queue"
  delay_seconds             = 0
  message_retention_seconds = 86400
  visibility_timeout_seconds = 30
}