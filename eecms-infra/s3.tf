resource "aws_s3_bucket" "postgres-db-exports-bucket" {
  bucket = "postgres-db-exports-bucket"
}

resource "aws_s3_bucket" "enriched-consumption-data-bucket" {
  bucket = "enriched-consumption-data-bucket"
}