# ┏━╸╻┏ ┏━┓
# ┣╸ ┣┻┓┗━┓
# ┗━╸╹ ╹┗━┛

# https://github.com/terraform-aws-modules/terraform-aws-eks
# https://github.com/awsdocs/amazon-eks-user-guide/tree/master/doc_source

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "k8s_vpc" {
  type        = string
  description = "VPC where EKS is to be deployed"
}

variable "k8s_subnets" {
  type        = list(any)
  description = "Subnet where eks cluster is to be deployed"
}

variable "k8s_control_subnets" {
  type        = list(any)
  description = "Subnets for the control plane deployment"
}

variable "k8s_module_version" {
  type        = string
  default     = "~> 19.7"
  description = "eks module version"
}

variable "k8s_cluster_version" {
  type        = string
  default     = "1.29"
  description = "Ref. https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html"
}

variable "lb_security_group_id" {
  type        = string
  description = "The security group of the load balancer"
}

variable "db_security_group_id" {
  type        = string
  description = "The security group of the database"
}

variable "self_managed_node_grp_instance_type" {
  type        = string
  default     = ""
  description = "Ref. https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt"
}

variable "self_managed_node_grp_default" {
  type    = any
  default = {}
}

variable "self_managed_node_grps" {
  type    = any
  default = {}
}

variable "managed_node_grp_default" {
  type        = list(any)
  default     = []
  description = "Ref. https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt"
}

variable "managed_node_grps" {
  type = any
}

variable "tags" {
  type    = any
  default = {}
}

variable "backend_app_port" {
  type        = number
  description = "The target port to use for the backend services"
}

variable "rds_port" {
  type        = number
  default     = 5432
  description = "RDS port"
}

variable "k8s_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDRs that are allowed to connect to the EKS control plane"
}

variable "k8s_access_bedrock" {
  type        = bool
  default     = false
  description = "Allow cluster to access bedrock in this region"
}

variable "bedrock_model_arn" {
  type        = string
  default     = ""
  description = "See ARN for bedrock model"
}

variable "k8s_api_access_roles" {
  type        = set(string)
  default     = []
  description = "Set of roles that can access the EKS API"
}
