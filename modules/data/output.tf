output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value = aws_db_instance.rds-database.endpoint
}

output "s3_bucket_backend" {
  description = "Name of the S3 bucket for the backend"
  value = aws_s3_bucket.main-bucket.id
}

output "s3_bucket_frontend" {
  description = "Name of the S3 bucket for the frontend"
  value = aws_s3_bucket.main-bucket-frontend.bucket_regional_domain_name
}