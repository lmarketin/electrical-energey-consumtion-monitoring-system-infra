resource "aws_cloudwatch_event_rule" "postgres_db_exporter_schedule_rule" {
  name                = "postgres_db_exporter_schedule_rule"
  schedule_expression = "cron(00 08 * * ? *)"
}

resource "aws_cloudwatch_event_target" "postgres_db_exporter_target" {
  rule      = aws_cloudwatch_event_rule.postgres_db_exporter_schedule_rule.name
  arn       = aws_sfn_state_machine.consumption_data_pipeline.arn
  role_arn  = aws_iam_role.cloudwatch_trigger_step_function_role.arn
}


