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

variable "vpc_private_subnets" {
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "private network cidr thats is included in var.vpc_cidr"
  validation {
    condition = alltrue([
      for cidr in var.vpc_private_subnets :
      can(regex("^(?:(?:\\d{1,3}\\.?){4})\\/(\\d{1,2})$", cidr))
    ])
    error_message = "Network CIDR must be a valid cidr."
  }
}

variable "vpc_public_subnets" {
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24"]
  description = "public network cidr thats is included in var.vpc_cidr"
  validation {
    condition = alltrue([
      for cidr in var.vpc_public_subnets :
      can(regex("^(?:(?:\\d{1,3}\\.?){4})\\/(\\d{1,2})$", cidr))
    ])
    error_message = "Network CIDR must be a valid cidr."
  }
}

variable "deploy_vpc_flow_logs" {
  type        = bool
  default     = false
  description = "Flag weither or not to deploy vpc flow logs"
}

variable "nat_gateway_public_ip" {
  type        = string
  default     = ""
  description = "Public IP of the NAT gateway when reusing the NAT gateway instead of recreating"
}

variable "vpc_propagating_vgws" {
  type        = list(any)
  default     = []
  description = "ID's of virtual private gateways to propagate."
}

variable "vpc_vpn_gateway_id" {
  type        = string
  default     = ""
  description = "ID of the VPN gateway to attach to the VPC"
}

variable "propagate_intra_route_tables_vgw" {
  type        = bool
  default     = false
  description = "If intra subnets should propagate traffic."
}

variable "propagate_private_route_tables_vgw" {
  type        = bool
  default     = false
  description = "If private subnets should propagate traffic."
}

variable "propagate_public_route_tables_vgw" {
  type        = bool
  default     = false
  description = "If public subnets should propagate traffic."
}

variable "dhcp_options_domain_name" {
  type        = string
  default     = ""
  description = ""
}

variable "dhcp_options_domain_name_servers" {
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
  description = "DNS resolver IPs"
}

variable "enable_dhcp_options" {
  type        = bool
  default     = false
  description = "Flag to use custom DHCP options for DNS resolution."
}

variable "dhcp_options_tags" {
  type        = map(string)
  default     = {}
  description = "To set the name of the DHCP options"
}

variable "provider_azs" {
  type        = list(string)
  default     = []
  description = "Provider AZs list, if empty we get AZs dynamically"
}

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "private_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "public_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "vpc_tags" {
  type    = map(any)
  default = {}
}
