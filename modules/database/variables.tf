#  ╺┳┓┏━┓╺┳╸┏━┓┏┓ ┏━┓┏━┓┏━╸
#   ┃┃┣━┫ ┃ ┣━┫┣┻┓┣━┫┗━┓┣╸
#  ╺┻┛╹ ╹ ╹ ╹ ╹┗━┛╹ ╹┗━┛┗━╸

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "rds_identifier" {
  type        = string
  default     = ""
  description = "Name of the RDS instance"
}

variable "provider_region" {
  type        = string
  description = "Region for deployment in AWS"
}

variable "vpc_private_subnets" {
  type        = list(any)
  description = "List of private subnets to deploy the database in"
}

variable "security_group_id" {
  type        = string
  description = "The security group to assign to the database"
}

variable "rds_username" {
  type        = string
  default     = "datafold"
  description = "RDS username"
}

variable "rds_instance" {
  type        = string
  default     = "db.t3.medium"
  description = <<-EOT
    EC2 insance type for PostgreSQL RDS database.
    Available instance groups: t3, m4, m5, r6i, m6i
    Available instance classes: medium and higher.
  EOT
  validation {
    condition     = can(regex("^db\\.(t3|m4|m5|r6i|m6i)\\..+$", var.rds_instance))
    error_message = "Instance type for rds is not valid."
  }
}

variable "rds_allocated_storage" {
  type        = number
  default     = 20
  description = "RDS allocated storage"
}

variable "rds_max_allocated_storage" {
  type        = number
  default     = 100
  description = "RDS max allocated storage"
}

variable "rds_backups_replication_target_region" {
  type        = string
  default     = null
  description = "RDS backup replication target region"
}

variable "rds_backups_replication_retention_period" {
  type        = number
  default     = 14
  description = "RDS backup replication retention period"
}

variable "rds_maintenance_window" {
  type        = string
  default     = "Mon:00:00-Mon:03:00"
  description = "RDS maintenance window"
}

variable "rds_backup_window" {
  type        = string
  default     = "03:00-06:00"
  description = "RDS backup window"
}

variable "rds_multi_az" {
  type        = bool
  default     = false
  description = "RDS instance in multiple AZ's"
}

variable "create_rds_kms_key" {
  type        = bool
  default     = true
  description = "RDS KMS key"
}

variable "rds_kms_key_alias" {
  type        = string
  default     = "datafold-rds"
  description = "RDS KMS key alias"
}

variable "use_default_rds_kms_key" {
  type        = bool
  default     = false
  description = "Flag weither or not to use the default RDS KMS encryption key. Not recommended to be used."
}

variable "db_subnet_group_name" {
  type        = string
  default     = ""
  description = "The specific subnet group name to use"
}

variable "db_parameter_group_name" {
  type        = string
  default     = ""
  description = "The specific parameter group name to associate"
}

variable "database_name" {
  type        = string
  default     = "datafold"
  description = "RDS database name"
}

variable "rds_ro_username" {
  type        = string
  default     = "datafold_ro"
  description = "RDS read-only user name"
}

variable "rds_version" {
  type        = string
  default     = "11.19"
  description = "Override RDS version"
}

variable "rds_port" {
  type        = number
  default     = 5432
  description = "RDS port"
}

variable "rds_param_group_family" {
  type        = string
  default     = "postgres11"
  description = "The parameter group family to apply"
}

variable "apply_major_upgrade" {
  type        = bool
  default     = false
  description = "Allows the plan to upgrade major version of the database."
}

variable "rds_performance_insights_enabled" {
  type        = bool
  default     = false
  description = "RDS performance insights enabled or not"
}

variable "db_instance_tags" {
  type    = map(any)
  default = {}
}

variable "db_parameter_group_tags" {
  type    = map(any)
  default = {}
}

variable "db_subnet_group_tags" {
  type    = map(any)
  default = {}
}

variable "rds_extra_tags" {
  type    = map(any)
  default = {}
}

variable "db_extra_parameters" {
  type        = list
  default     = []
  description = "List of map of extra variables to apply to the RDS database parameter group"
}

variable "rds_copy_tags_to_snapshot" {
  type        = bool
  default     = false
  description = "To copy tags to snapshot or not"
}

variable "rds_performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "RDS performance insights retention period"
}

variable "rds_auto_minor_version_upgrade" {
  type        = bool
  default     = false
  description = "Sets a flag to upgrade automatically all minor versions"
}

variable "rds_monitoring_interval" {
  type        = number
  default     = 0
  description = "RDS monitoring interval"
}
