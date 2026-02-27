output "temporal_s3_bucket" {
  value = aws_s3_bucket.temporal_backup.id
}

output "temporal_s3_bucket_arn" {
  value = aws_s3_bucket.temporal_backup.arn
}

output "temporal_s3_region" {
  value = aws_s3_bucket.temporal_backup.region
}
