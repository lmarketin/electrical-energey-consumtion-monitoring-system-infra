resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Allow PostgreSQL traffic from only the web sg"
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id, var.exporter_lambda_sg_id]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db_subnet_group"
  subnet_ids  = [var.private_subnet_1_id, var.private_subnet_2_id]
}

resource "aws_db_instance" "pgsql" {
  allocated_storage      = var.settings.database.allocated_storage
  engine                 = var.settings.database.engine
  engine_version         = var.settings.database.engine_version
  instance_class         = var.settings.database.instance_class
  db_name                = var.settings.database.db_name
  username               = var.db_username
  password               = var.db_password
  identifier             = var.settings.database.identifier
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = var.settings.database.skip_final_snapshot
}
