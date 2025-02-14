resource "aws_lambda_function" "postgres_db_exporter" {
  function_name    = "postgres_db_exporter"
  role            = aws_iam_role.postgres_db_exporter.arn
  runtime         = "python3.8"
  handler         = "postgres_db_exporter.lambda_handler"
  source_code_hash = data.archive_file.postgres_db_exporter_zip.output_base64sha256
  filename        = data.archive_file.postgres_db_exporter_zip.output_path
  timeout         = 15

  environment {
    variables = {
      DB_HOST     = "pgsql.cr66uewyk9gp.eu-central-1.rds.amazonaws.com"
      DB_NAME     = "pgsql"
      DB_USER     = "db_admin"
      DB_PASSWORD = "dipl_rad_31"
    }
  }

   vpc_config {
    subnet_ids         = ["subnet-0149734d1ce4e7128", "subnet-0c2d84e8b882d459b"]//TODO istovremeno dodati oba polja
    security_group_ids = [aws_security_group.postgres_db_exporter_sg.id] //TODO ne kreira se odma zbod vpc_id
  }
}

data "archive_file" "postgres_db_exporter_zip" {
  type = "zip"
  output_path = "${path.module}/artifacts/postgre_db_exporter.zip"
  source_dir = "${path.module}/source"
}


