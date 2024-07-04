variable "allowed_principals" {
  type  = list(string)
  description = "List of allowed principals to connect to the endpoint"
}

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "control_plane_sg_id" {
  type        = string
  description = "ID of the security group of EKS cluster control plane."
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID of an existing VPC to deploy the cluster in. Creates a new VPC if not set."
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "List of private subnets to deploy the database in"
}

variable "vpn_cidr" {
  type        = string
  description = "The CIDR range where VPN or instances accessing this control plane originate."
}
