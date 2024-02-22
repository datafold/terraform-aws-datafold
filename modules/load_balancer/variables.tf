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

variable "vpc_public_subnets" {
  type        = list(any)
  description = "List of private subnets to deploy the database in"
}

variable "security_group_id" {
  type        = string
  description = "The security group to assign to the database"
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

variable "lb_internal" {
  type        = bool
  default     = false
  description = "Flag if the application LB is internal, needed for some VPN setups."
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
