resource "aws_s3_bucket" "temporal_backup" {
  bucket = var.s3_bucket_name_override == "" ? "${var.deployment_name}-${var.temporal_s3_bucket}" : var.s3_bucket_name_override
  tags   = var.s3_temporal_backup_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "temporal_backup" {
  bucket = aws_s3_bucket.temporal_backup.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "temporal_backup" {
  bucket = aws_s3_bucket.temporal_backup.bucket

  rule {
    id = "backup_retention"
    expiration {
      days = var.backup_lifecycle_expiration_days
    }
    filter {}
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "temporal_backup" {
  bucket = aws_s3_bucket.temporal_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
