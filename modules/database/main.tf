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
  identifier = var.deployment_name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = var.rds_version
  family               = var.rds_param_group_family
  major_engine_version = var.rds_version
  instance_class       = var.rds_instance
  ca_cert_identifier   = "rds-ca-rsa2048-g1"

  allow_major_version_upgrade = var.apply_major_upgrade

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
  password                    = random_password.rds_master_password.result
  port                        = var.rds_port

  multi_az               = false
  create_db_subnet_group = true
  subnet_ids             = var.vpc_private_subnets
  vpc_security_group_ids = [var.security_group_id]

  apply_immediately               = true
  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
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

  performance_insights_enabled = false
  create_monitoring_role       = false

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
