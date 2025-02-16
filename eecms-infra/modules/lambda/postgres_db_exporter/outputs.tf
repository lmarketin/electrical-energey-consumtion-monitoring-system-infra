output "postgres_db_exporter_lambda_arn" {
  value = aws_lambda_function.postgres_db_exporter.arn
}

output "postgres_db_exporter_lambda_sg_id" {
  value = aws_security_group.postgres_db_exporter_sg.id
}