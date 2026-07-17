# KMS key for encrypting RDS instance.
# Not created (and the alias not looked up) when an external key ARN is
# passed in via rds_kms_key_arn — aliases only resolve in the caller's
# account, so cross-account keys must be referenced by key ARN.
resource "aws_kms_key" "rds" {
  count               = var.create_rds_kms_key && var.rds_kms_key_arn == null ? 1 : 0
  multi_region        = true
  description         = "KMS key for RDS"
  enable_key_rotation = true
}

resource "aws_kms_alias" "rds" {
  count         = var.create_rds_kms_key && var.rds_kms_key_arn == null ? 1 : 0
  name          = "alias/${var.rds_kms_key_alias}"
  target_key_id = one(resource.aws_kms_key.rds[*].key_id)
}

data "aws_kms_key" "rds" {
  count  = var.rds_kms_key_arn == null ? 1 : 0
  key_id = "alias/${var.rds_kms_key_alias}"

  depends_on = [
    aws_kms_alias.rds
  ]
}

resource "random_password" "rds_master_password" {
  length  = 16
  special = false
}

resource "random_password" "postgres_ro_password" {
  length           = 16
  special          = true
  override_special = "!%&-_"
}
