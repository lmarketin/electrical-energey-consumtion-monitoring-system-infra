output "postgres_db_consumption_data_exports_bucket_name" {
  value = aws_s3_bucket.postgres-db-consumption-data-exports-bucket.bucket
}

output "enriched-consumption-data-bucket_name" {
  value = aws_s3_bucket.enriched-consumption-data-bucket.bucket
}