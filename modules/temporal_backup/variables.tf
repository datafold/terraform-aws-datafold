# ╺┳╸┏━╸┏┳┓┏━┓┏━┓┏━┓┏━┓╻
#  ┃ ┣╸ ┃┃┃┣━┛┃ ┃┣┳┛┣━┫┃
#  ╹ ┗━╸╹ ╹╹  ┗━┛╹┗╸╹ ╹┗━╸

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "temporal_s3_bucket" {
  type        = string
  default     = "temporal-pg-backups"
  description = "Suffix for the Temporal PostgreSQL backup S3 bucket name."
}

variable "s3_bucket_name_override" {
  type        = string
  default     = ""
  description = "Override the full Temporal backup S3 bucket name."
}

variable "backup_lifecycle_expiration_days" {
  type        = number
  default     = 7
  description = "Number of days after which Temporal PostgreSQL backup objects will expire and be deleted."
}

variable "s3_temporal_backup_tags" {
  type    = map(any)
  default = {}
}
