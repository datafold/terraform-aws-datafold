#  ┏━╸╻  ╻┏━╸╻┏ ╻ ╻┏━┓╻ ╻┏━┓┏━╸
#  ┃  ┃  ┃┃  ┣┻┓┣━┫┃ ┃┃ ┃┗━┓┣╸
#  ┗━╸┗━╸╹┗━╸╹ ╹╹ ╹┗━┛┗━┛┗━┛┗━╸

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "s3_clickhouse_backup_tags" {
  type    = map(any)
  default = {}
}

variable "clickhouse_s3_bucket" {
  type        = string
  default     = "clickhouse-backups-abcguo23"
  description = "Bucket for clickhouse backups."
}

variable "s3_backup_bucket_name_override" {
  type        = string
  default     = ""
  description = "Bucket name override."
}
