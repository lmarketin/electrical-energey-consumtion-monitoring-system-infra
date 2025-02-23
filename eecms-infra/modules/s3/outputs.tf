output "postgres_db_consumption_data_exports_bucket_domain_name" {
  value = aws_s3_bucket.postgres-db-consumption-data-exports-bucket.bucket
}