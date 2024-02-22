#  ┏━┓┏━╸┏━╸╻ ╻┏━┓╻╺┳╸╻ ╻   ┏━╸┏━┓┏━┓╻ ╻┏━┓┏━┓
#  ┗━┓┣╸ ┃  ┃ ┃┣┳┛┃ ┃ ┗┳┛   ┃╺┓┣┳┛┃ ┃┃ ┃┣━┛┗━┓
#  ┗━┛┗━╸┗━╸┗━┛╹┗╸╹ ╹  ╹    ┗━┛╹┗╸┗━┛┗━┛╹  ┗━┛

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "vpc_cidr"  {
  type        = string
  description = "CIDR range of the VPC."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID where everything is deployed"
}

variable "whitelisted_ingress_cidrs" {
  type        = list(string)
  description = "List of CIDRs that can access the HTTP/HTTPS"
  validation {
    condition = alltrue([
      for ip in var.whitelisted_ingress_cidrs :
      can(regex("^((?:\\d{1,3}\\.?){4})\\/(\\d{1,2})$", ip))
    ])
    error_message = "Network CIDR must be a valid cidr."
  }
}

variable "whitelisted_egress_cidrs" {
  type        = list(string)
  description = "List of Internet addresses to which the application has access"
  validation {
    condition = alltrue([
      for ip in var.whitelisted_egress_cidrs :
      can(regex("^((?:\\d{1,3}\\.?){4})\\/(\\d{1,2})$", ip))
    ])
    error_message = "Network CIDR must be a valid cidr."
  }
}

variable "ingress_enable_http_sg" {
  type        = bool
  default     = false
  description = "Weither or not to also enable HTTP ingress rules for SG besides HTTPS."
}

variable "dns_egress_cidrs" {
  type        = list(string)
  description = "List of Internet addresses to which the application has access"
  default     = []
  validation {
    condition = alltrue([
      for ip in var.dns_egress_cidrs :
      can(regex("^((?:\\d{1,3}\\.?){4})\\/(\\d{1,2})$", ip))
    ])
    error_message = "Network CIDR must be a valid cidr."
  }
}

variable "sg_tags" {
  type    = map(any)
  default = {}
}
