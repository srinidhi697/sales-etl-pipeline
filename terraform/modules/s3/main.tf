# Create the main S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = "${var.project}-${var.env}-datalake"

  force_destroy = true   # allows bucket to be destroyed even if not empty (useful for dev)
}

# Enable versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create folder structure (raw, silver, gold)
resource "aws_s3_object" "folders" {
  for_each = toset(["raw/", "silver/", "gold/"])

  bucket  = aws_s3_bucket.this.id
  key     = each.value
  content = ""   # empty object to represent "folder"
}
