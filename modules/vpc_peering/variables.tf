variable "deployment_name" {
  description = "The name of the deployment"
  type        = string
}

variable "lb_security_group_id" {
  description = "The security group ID managing ingress from the load balancer"
  type        = string
}

variable "ingress_enable_http_sg" {
  description = "Whether to enable HTTP ingress rules"
  default     = false
  type        = bool
}

variable "peer_owner_id" {
  description = "The AWS account ID of the owner of the peer VPC"
  type        = string
}

variable "peer_region" {
  description = "The region of the peer VPC"
  type        = string
}

variable "peer_vpc_cidr_block" {
  description = "The CIDR block of the peer VPC"
  type        = string
}

variable "peer_vpc_additional_whitelisted_ingress_cidrs" {
  description = "List of CIDRs that can pass through the load balancer"
  type        = set(string)
}

variable "peer_vpc_id" {
  description = "The ID of the peer VPC"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_subnets" {
  description = "The subnets of the VPC"
  type        = list(any)
}