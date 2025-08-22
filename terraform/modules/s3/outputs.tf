output "bucket_name" {
  description = "The name of the S3 data lake bucket"
  value       = aws_s3_bucket.this.bucket
}
