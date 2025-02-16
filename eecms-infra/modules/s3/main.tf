resource "aws_s3_bucket" "postgres-db-consumption-data-exports-bucket" {
  bucket = "postgres-db-consumption-data-exports-bucket"
}

resource "aws_s3_bucket" "enriched-consumption-data-bucket" {
  bucket = "enriched-consumption-data-bucket"
}