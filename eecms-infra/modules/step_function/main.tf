resource "aws_sfn_state_machine" "consumption_data_pipeline" {
  name     = "consumption_data_pipeline"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Step Function for data processing pipeline",
    StartAt = "ExportingLambda",
    States = {
      ExportingLambda = {
        Type     = "Task",
        Resource = var.exporter_lambda_arn,
        Next     = "EnrichingLambda"
      },
      EnrichingLambda = {
        Type     = "Task",
        Resource = var.enricher_lambda_arn
        Next     = "AlertingLambda"
      },
      AlertingLambda = {
        Type     = "Task",
        Resource = var.alerting_lambda_arn
        End      = true
      },

    }
  })
}