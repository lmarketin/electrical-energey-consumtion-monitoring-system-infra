resource "aws_lambda_function" "postgres_db_exporter" {
  function_name    = "postgres_db_exporter"
  role            = aws_iam_role.postgres_db_exporter_role.arn
  runtime         = "python3.8"
  handler         = "postgres_db_exporter.lambda_handler"
  source_code_hash = data.archive_file.postgres_db_exporter_zip.output_base64sha256
  filename        = data.archive_file.postgres_db_exporter_zip.output_path
  timeout         = 15

  environment {
    variables = {
      DB_HOST     = "pgsql.cr66uewyk9gp.eu-central-1.rds.amazonaws.com"//TODO
      DB_NAME     = "pgsql"
      DB_USER     = "db_admin"
      DB_PASSWORD = "dipl_rad_31"
    }
  }

   vpc_config {
    subnet_ids         = [var.private_subnet_1_id, var.private_subnet_2_id]
    security_group_ids = [aws_security_group.postgres_db_exporter_sg.id]
  }
}

data "archive_file" "postgres_db_exporter_zip" {
  type = "zip"
  output_path = "${path.module}/artifacts/postgre_db_exporter.zip"
  source_dir = "${path.module}/source"
}

#SG
resource "aws_security_group" "postgres_db_exporter_sg" {
  name_prefix = "postgres_db_exporter_sg"
  vpc_id      = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


