output "clickhouse_s3_bucket" {
  value = "${var.deployment_name}-${var.clickhouse_s3_bucket}"
}

output "clickhouse_s3_region" {
  value = resource.aws_s3_bucket.clickhouse_backup.region
}

output "clickhouse_access_key" {
  value = resource.aws_iam_access_key.clickhouse_backup.id
}

output "clickhouse_secret_key" {
  value = resource.aws_iam_access_key.clickhouse_backup.secret
}
