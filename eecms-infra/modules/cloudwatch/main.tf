resource "aws_cloudwatch_event_rule" "consumption_data_pipeline_event_rule" {
  name                = "consumption_data_pipeline_event_rule"
  schedule_expression = "cron(27 10 * * ? *)"
}

resource "aws_cloudwatch_event_target" "consumption_data_pipeline_event_target" {
  rule      = aws_cloudwatch_event_rule.consumption_data_pipeline_event_rule.name
  arn       = var.consumption_data_pipeline_state_machine_arn
  role_arn  = aws_iam_role.consumption_data_pipeline_event_role.arn
}


