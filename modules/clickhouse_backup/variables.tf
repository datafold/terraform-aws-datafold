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