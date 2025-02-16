resource "aws_sns_topic" "admin_email_topic" {
  name = "admin_email_topic"
}

resource "aws_sns_topic_subscription" "admin_email_subscription" {
  topic_arn = aws_sns_topic.admin_email_topic.arn
  protocol  = "email"
  endpoint  = "lmarketin@tvz.hr"
}