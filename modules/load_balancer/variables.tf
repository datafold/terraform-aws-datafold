#  ╻  ┏━┓┏━┓╺┳┓   ┏┓ ┏━┓╻  ┏━┓┏┓╻┏━╸┏━╸┏━┓
#  ┃  ┃ ┃┣━┫ ┃┃╺━╸┣┻┓┣━┫┃  ┣━┫┃┗┫┃  ┣╸ ┣┳┛
#  ┗━╸┗━┛╹ ╹╺┻┛   ┗━┛╹ ╹┗━╸╹ ╹╹ ╹┗━╸┗━╸╹┗╸

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "Provide ID of existing VPC if you want to omit creation of new one"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Network CIDR for VPC"
  validation {
    condition     = can(regex("^(?:(?:\\d{1,3}\\.?){4})\\/(\\d{1,2})$", var.vpc_cidr))
    error_message = "Network CIDR must be a valid cidr."
  }
}

variable "vpc_public_subnets" {
  type        = list(any)
  description = "List of private subnets to deploy the database in"
}

variable "security_group_id" {
  type        = string
  description = "The security group to assign to the load balancer"
}

variable "create_ssl_cert" {
  type        = bool
  description = "Flag weither or not to create a SSL certificate."
}

variable "alb_certificate_domain" {
  type        = string
  description = <<-EOT
    Pass a domain name like example.com to this variable in order to enable ALB HTTPS listeners.
    Terraform will try to find AWS certificate that is issued and matches asked domain,
    so please make sure that you have issued a certificate for asked domain already.
  EOT
}

variable "lb_name_override" {
  type        = string
  default     = ""
  description = "An optional override for the name of the load balancer"
}

variable "lb_internal" {
  type        = bool
  default     = false
  description = "Flag if the application LB is internal, needed for some VPN setups."
}

variable "lb_deletion_protection" {
  type        = bool
  default     = true
  description = "Flag if the load balancer can be deleted or not."
}

variable "lb_idle_timeout" {
  type        = number
  default     = 120
  description = "The time in seconds that the connection is allowed to be idle."
}

variable "backend_app_port" {
  type        = number
  default     = 80
  description = "The target port to use for the backend services"
}

variable "lb_access_logs" {
  type        = map(string)
  default     = {}
  description = "Load balancer access logs configuration."
}

variable "lb_deploy_nlb" {
  type        = bool
  default     = false
  description = "Flag if the network load balancer should be deployed (usually for incoming private link)."
}

variable "vpces_security_group_id" {
  type        = string
  default     = ""
  description = "The security group to assign to the VPCES"
}

variable "lb_vpces_details" {
  default = null
  type = object({
    allowed_principals  = list(string)
    private_dns_name    = optional(string)
    acceptance_required = bool

    supported_ip_address_types = list(string)
  })
  description = "Endpoint service to define for internal traffic over private link"
}