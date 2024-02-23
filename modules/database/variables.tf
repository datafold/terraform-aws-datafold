#  ╺┳┓┏━┓╺┳╸┏━┓┏┓ ┏━┓┏━┓┏━╸
#   ┃┃┣━┫ ┃ ┣━┫┣┻┓┣━┫┗━┓┣╸
#  ╺┻┛╹ ╹ ╹ ╹ ╹┗━┛╹ ╹┗━┛┗━╸

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
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
    EC2 instance type for PostgreSQL RDS database.
    Available instance groups: t3, m4, m5.
    Available instance classes: medium and higher.
  EOT
  validation {
    condition     = can(regex("^db\\.(t3|m4|m5)\\..+$", var.rds_instance))
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
