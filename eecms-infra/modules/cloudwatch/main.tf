resource "aws_cloudwatch_event_rule" "postgres_db_exporter_schedule_rule" {
  name                = "postgres_db_exporter_schedule_rule"
  schedule_expression = "cron(57 19 * * ? *)"
}

resource "aws_cloudwatch_event_target" "postgres_db_exporter_target" {
  rule      = aws_cloudwatch_event_rule.postgres_db_exporter_schedule_rule.name
  arn       = var.consumption_data_pipeline_arn
  role_arn  = aws_iam_role.cloudwatch_trigger_step_function_role.arn
}


