provider "aws" {
  region = var.region
}

resource "aws_sfn_state_machine" "consumption_data_pipeline" {
  name     = "consumption_data_pipeline"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Step Function for data processing pipeline",
    StartAt = "ExportingLambda",
    States = {
      ExportingLambda = {
        Type     = "Task",
        Resource = module.postgres_db_exporter.postgres_db_exporter_lambda_arn,
        Next     = "EnrichingLambda"
      },
      EnrichingLambda = {
        Type     = "Task",
        Resource = module.consumption_data_enricher.consumption_data_enricher_lambda_arn
        Next     = "AlertingLambda"
      },
      AlertingLambda = {
        Type     = "Task",
        Resource = module.not_received_consumption_data_alert.not_received_consumption_data_alert_lambda_arn
        End      = true
      },

    }
  })
}