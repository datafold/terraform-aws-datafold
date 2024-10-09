# ┏━╸╻╺┳╸╻ ╻╻ ╻┏┓    ┏━┓┏━╸╻ ╻┏━╸┏━┓┏━┓┏━╸   ┏━┓┏━┓┏━┓╻ ╻╻ ╻
# ┃╺┓┃ ┃ ┣━┫┃ ┃┣┻┓   ┣┳┛┣╸ ┃┏┛┣╸ ┣┳┛┗━┓┣╸    ┣━┛┣┳┛┃ ┃┏╋┛┗┳┛
# ┗━┛╹ ╹ ╹ ╹┗━┛┗━┛   ╹┗╸┗━╸┗┛ ┗━╸╹┗╸┗━┛┗━╸   ╹  ╹┗╸┗━┛╹ ╹ ╹

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "environment" {
  type        = string
  description = "Global environment tag to apply on all datadog logs, metrics, etc."
}

variable "region" {
  type        = string
  description = "Region to deploy API Gateway and lambda's to in AWS"
}

variable "vpc_id" {
  description = "The VPC where Lambda will be deployed"
}

variable "vpc_private_subnets" {
  description = "List of subnet IDs for Lambda to run in"
  type        = list(string)
}

variable "vpc_cidr" {
  type        = string
  description = "Network CIDR for VPC"
  validation {
    condition     = can(regex("^(?:(?:\\d{1,3}\\.?){4})\\/(\\d{1,2})$", var.vpc_cidr))
    error_message = "Network CIDR must be a valid cidr."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs for Lambda. If non provided, it will use the lambda_sg."
  type        = list(string)
  default     = []
}

variable "github_secret" {
  description = "GitHub webhook secret"
  type        = string
}

variable "private_system_endpoint" {
  description = "Private system endpoint to forward the webhook"
  type        = string
}