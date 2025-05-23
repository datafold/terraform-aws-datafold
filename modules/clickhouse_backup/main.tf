resource "aws_s3_bucket" "clickhouse_backup" {
  bucket = var.s3_backup_bucket_name_override == "" ? "${var.deployment_name}-${var.clickhouse_s3_bucket}" : var.s3_backup_bucket_name_override
  tags   = var.s3_clickhouse_backup_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "clickhouse_backup" {
  bucket = aws_s3_bucket.clickhouse_backup.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "clickhouse_backup" {
  bucket = aws_s3_bucket.clickhouse_backup.bucket

  rule {
    id = "two_week_retention"
    expiration {
      days = 14
    }
    filter {}
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "clickhouse_backup" {
  bucket = aws_s3_bucket.clickhouse_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
