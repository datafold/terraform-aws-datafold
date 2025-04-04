# Restoring from a snapshot:

# Uncomment the data block. That will pick up the most recent prod snapshot
# Also uncomment the block in the db identifier

# data "aws_db_snapshot" "latest_snapshot" {
#   db_instance_identifier = module.db.db_instance_id
#   most_recent            = true
# }

# https://registry.terraform.io/moduleßs/terraform-aws-modules/rds/aws/3.3.0
module "db" {
  count      = 1
  source     = "terraform-aws-modules/rds/aws"
  version    = "~> 6.0.0"
  identifier = var.rds_identifier == "" ? var.deployment_name : var.rds_identifier

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = var.rds_version
  family               = var.rds_param_group_family
  major_engine_version = var.rds_version
  instance_class       = var.rds_instance
  ca_cert_identifier   = "rds-ca-rsa2048-g1"

  allow_major_version_upgrade = var.apply_major_upgrade
  auto_minor_version_upgrade  = var.rds_auto_minor_version_upgrade

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_encrypted     = true
  kms_key_id            = var.use_default_rds_kms_key ? null : data.aws_kms_key.rds.arn

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                     = var.database_name
  username                    = var.rds_username
  manage_master_user_password = false
  password                    = local.rds_password
  port                        = var.rds_port
  copy_tags_to_snapshot       = var.rds_copy_tags_to_snapshot

  multi_az                        = var.rds_multi_az
  create_db_subnet_group          = true
  db_subnet_group_use_name_prefix = var.db_subnet_group_name == "" ? true : false
  db_subnet_group_name            = var.db_subnet_group_name
  subnet_ids                      = var.vpc_private_subnets
  vpc_security_group_ids          = [var.security_group_id]
  parameter_group_name            = var.db_parameter_group_name
  parameter_group_use_name_prefix = var.db_parameter_group_name == "" ? true : false
  create_db_parameter_group       = var.db_parameter_group_name == "" ? true : false
  apply_immediately               = true
  maintenance_window              = var.rds_maintenance_window
  backup_window                   = var.rds_backup_window
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Only uncomment this if ever a restore needs to happen
  # from a snapshot
  # snapshot_identifier = data.aws_db_snapshot.latest_prod_snapshot.id
  # lifecycle {
  #   ignore_changes = [snapshot_identifier]
  # }

  backup_retention_period = var.rds_backups_replication_retention_period
  skip_final_snapshot     = false
  deletion_protection     = true

  performance_insights_enabled = var.rds_performance_insights_enabled
  create_monitoring_role       = false
  monitoring_role_arn          = var.rds_monitoring_role_arn
  monitoring_interval          = var.rds_monitoring_interval

  performance_insights_retention_period = var.rds_performance_insights_retention_period

  parameters = concat([
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ], var.db_extra_parameters)

  tags = merge({
    component = "app"
    Name      = var.deployment_name
  }, var.rds_extra_tags)

  db_instance_tags        = var.db_instance_tags
  db_parameter_group_tags = var.db_parameter_group_tags
  db_subnet_group_tags    = var.db_subnet_group_tags

  timeouts = {
    "create" : "40m",
    "delete" : "40m",
    "update" : "80m"
  }
}

locals {
  log_rds_automated_backups_replication_path = "${path.module}/../../logs/rds_automated_backups_replication.log"
  rds_password = var.rds_password_override != null ? var.rds_password_override : random_password.rds_master_password.result
}

# https://docs.aws.amazon.com/cli/latest/reference/rds/start-db-instance-automated-backups-replication.html
resource "null_resource" "rds-automated-backups-replication" {
  count = var.rds_backups_replication_target_region != null ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      aws rds start-db-instance-automated-backups-replication \
        --source-db-instance-arn ${one(module.db[*].db_instance_arn)} \
        --kms-key-id ${data.aws_kms_key.rds.id} \
        --source-region ${var.provider_region} \
        --region ${var.rds_backups_replication_target_region} \
        --backup-retention-period ${var.rds_backups_replication_retention_period} \
        > ${local.log_rds_automated_backups_replication_path}
    EOT
  }
}

data "local_file" "log_rds_automated_backups_replication" {
  count    = var.rds_backups_replication_target_region != null ? 1 : 0
  filename = local.log_rds_automated_backups_replication_path
}

output "log_rds_automated_backups_replication" {
  value = one(data.local_file.log_rds_automated_backups_replication[*].content)
}
