output "pgsql_endpoint" {
  value = split(":", aws_db_instance.pgsql.endpoint)[0]
}