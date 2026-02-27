output "clickhouse_s3_bucket" {
  value = resource.aws_s3_bucket.clickhouse_backup.id
}

output "clickhouse_s3_bucket_arn" {
  value = resource.aws_s3_bucket.clickhouse_backup.arn
}

output "clickhouse_s3_region" {
  value = resource.aws_s3_bucket.clickhouse_backup.region
}
