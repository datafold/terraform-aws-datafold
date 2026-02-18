# ╺┳╸┏━┓┏━╸┏━┓
#  ┃ ┣━┫┃╺┓┗━┓
#  ╹ ╹ ╹┗━┛┗━┛

variable "db_instance_tags" {
  type        = map(any)
  default     = {}
  description = "The extra tags to be applied to the RDS instance."
}

variable "db_parameter_group_tags" {
  type        = map(any)
  default     = {}
  description = "The extra tags to be applied to the parameter group"
}

variable "db_subnet_group_tags" {
  type        = map(any)
  default     = {}
  description = "The extra tags to be applied to the parameter group"
}

variable "rds_extra_tags" {
  type        = map(any)
  default     = {}
  description = "The extra tags to be applied to the RDS instance"
}

variable "ebs_extra_tags" {
  type        = map(any)
  default     = {}
  description = "The extra tags to be applied to the EBS volumes"
}

variable "private_subnet_tags" {
  type        = map(any)
  default     = { Tier = "private" }
  description = "The extra tags to be applied to the private subnets"
}

variable "public_subnet_tags" {
  type        = map(any)
  default     = { Tier = "public" }
  description = "The extra tags to be applied to the public subnets"
}

variable "vpc_tags" {
  type        = map(any)
  default     = {}
  description = "The extra tags to be applied to the VPC"
}

variable "s3_clickhouse_backup_tags" {
  type        = map(any)
  default     = {}
  description = "The extra tags to be applied to the S3 clickhouse backup bucket"
}

variable "sg_tags" {
  type        = map(any)
  default     = {}
  description = "The extra tags to be applied to the security group"
}

#  ╻ ╻┏━┓┏━┓╻┏━┓┏┓ ╻  ┏━╸┏━┓
#  ┃┏┛┣━┫┣┳┛┃┣━┫┣┻┓┃  ┣╸ ┗━┓
#  ┗┛ ╹ ╹╹┗╸╹╹ ╹┗━┛┗━╸┗━╸┗━┛

#  ┏━╸┏━┓┏┳┓┏┳┓┏━┓┏┓╻
#  ┃  ┃ ┃┃┃┃┃┃┃┃ ┃┃┗┫
#  ┗━╸┗━┛╹ ╹╹ ╹┗━┛╹ ╹

variable "deployment_name" {
  type        = string
  description = "Name of the current deployment."
}

variable "environment" {
  type        = string
  description = "Global environment tag to apply on all datadog logs, metrics, etc."
}

variable "redis_data_size" {
  type        = number
  default     = 50
  description = "Redis EBS volume size in GB"
}

variable "az_index" {
  type        = number
  default     = 0
  description = "Index of the availability zone"
}

variable "public_subnet_index" {
  type        = number
  default     = 0
  description = "Index of the public subnet"
}

variable "private_subnet_index" {
  type        = number
  default     = 0
  description = "Index of the private subnet"
}

variable "secondary_private_subnet_index" {
  type        = number
  default     = null
  description = "Index of the private subnet for secondary node groups (grp4, grp5, grp6). If null, uses private_subnet_index."
}

variable "eks_cluster_subnet_count" {
  type        = number
  default     = null
  description = "Number of private subnets to use for EKS cluster (control plane). If null, uses all private subnets. Set this to limit which subnets the EKS cluster uses while allowing node groups to use additional subnets."
}

variable "initial_apply_complete" {
  type        = bool
  default     = false
  description = "Indicates if this infra is deployed or not. Helps to resolve dependencies."
}

#  ┏━┓┏━┓┏━┓╻ ╻╻╺┳┓┏━╸┏━┓
#  ┣━┛┣┳┛┃ ┃┃┏┛┃ ┃┃┣╸ ┣┳┛
#  ╹  ╹┗╸┗━┛┗┛ ╹╺┻┛┗━╸╹┗╸

variable "provider_region" {
  type        = string
  description = "The AWS region in which the infrastructure should be deployed"
}

variable "provider_azs" {
  type        = list(string)
  default     = []
  description = "List of availability zones to consider. If empty, the modules will determine this dynamically."
}

#  ╻ ╻┏━┓┏━╸
#  ┃┏┛┣━┛┃
#  ┗┛ ╹  ┗━╸

variable "vpc_id" {
  type        = string
  default     = ""
  description = "The VPC ID of an existing VPC to deploy the cluster in. Creates a new VPC if not set."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR of the new VPC, if the vpc_cidr is not set"
  validation {
    condition     = can(regex("^(?:(?:\\d{1,3}\\.?){4})\\/(\\d{1,2})$", var.vpc_cidr))
    error_message = "Network CIDR must be a valid cidr."
  }
}

variable "vpc_private_subnets" {
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "The private subnet CIDR ranges when a new VPC is created."
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
  description = "The public network CIDR ranges"
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
  description = "Activates the VPC flow logs if set."
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
  description = "Specifies DNS name for DHCP options set"
}

variable "dhcp_options_domain_name_servers" {
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
  description = "Specify a list of DNS server addresses for DHCP options set"
}

variable "enable_dhcp_options" {
  type        = bool
  default     = false
  description = "Flag to use custom DHCP options for DNS resolution."
}

variable "dhcp_options_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the DHCP options set."
}

variable "vpce_details" {
  default = {}
  type = map(object({
    vpces_service_name  = string
    subnet_ids          = optional(list(string), [])
    private_dns_enabled = optional(bool, true)

    input_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = string
    }))
    output_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = string
    }))
  }))
  description = "Endpoint names to define with security group rule definitions"
}

variable "vpc_exclude_az_ids" {
  type        = list(string)
  default     = []
  description = "AZ IDs to exclude from availability zones"
}

#  ┏━┓┏━╸┏━╸╻ ╻┏━┓╻╺┳╸╻ ╻   ┏━╸┏━┓┏━┓╻ ╻┏━┓┏━┓
#  ┗━┓┣╸ ┃  ┃ ┃┣┳┛┃ ┃ ┗┳┛   ┃╺┓┣┳┛┃ ┃┃ ┃┣━┛┗━┓
#  ┗━┛┗━╸┗━╸┗━┛╹┗╸╹ ╹  ╹    ┗━┛╹┗╸┗━┛┗━┛╹  ┗━┛

variable "whitelisted_ingress_cidrs" {
  type        = list(string)
  description = "List of CIDRs that can pass through the load balancer"
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
  description = "List of Internet addresses the application can access going outside"
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
  description = "Whether regular HTTP traffic should be allowed to access the load balancer"
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

#  ╻  ┏━┓┏━┓╺┳┓   ┏┓ ┏━┓╻  ┏━┓┏┓╻┏━╸┏━╸┏━┓
#  ┃  ┃ ┃┣━┫ ┃┃╺━╸┣┻┓┣━┫┃  ┣━┫┃┗┫┃  ┣╸ ┣┳┛
#  ┗━╸┗━┛╹ ╹╺┻┛   ┗━┛╹ ╹┗━╸╹ ╹╹ ╹┗━╸┗━╸╹┗╸

variable "create_ssl_cert" {
  type        = bool
  description = "Creates an SSL certificate if set."
}

variable "lb_subnets_override" {
  description = "Override subnets to deploy ALB into, otherwise use default logic."
  type        = list(string)
  default     = []
}

variable "alb_certificate_domain" {
  type        = string
  description = <<-EOT
    Pass a domain name like example.com to this variable in order to enable ALB HTTPS listeners.
    Terraform will try to find AWS certificate that is issued and matches asked domain,
    so please make sure that you have issued a certificate for asked domain already.
  EOT
}

variable "host_override" {
  type        = string
  default     = ""
  description = "Overrides the default domain name used to send links in invite emails and page links. Useful if the application is behind cloudflare for example."
}

variable "lb_internal" {
  type        = bool
  default     = false
  description = "Set to true to make the load balancer internal and not exposed to the internet."
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

variable "lb_deletion_protection" {
  type        = bool
  default     = true
  description = "Flag if the load balancer can be deleted or not."
}

variable "lb_name_override" {
  type        = string
  default     = ""
  description = "An optional override for the name of the load balancer"
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

variable "lb_nlb_internal" {
  type        = bool
  default     = true
  description = "Set to true to make the load balancer internal and not exposed to the internet."
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

variable "deploy_lb" {
  type        = bool
  default     = true
  description = "Allows a deploy without a load balancer"
}

#  ╺┳┓┏━┓╺┳╸┏━┓┏┓ ┏━┓┏━┓┏━╸
#   ┃┃┣━┫ ┃ ┣━┫┣┻┓┣━┫┗━┓┣╸
#  ╺┻┛╹ ╹ ╹ ╹ ╹┗━┛╹ ╹┗━┛┗━╸

variable "create_rds" {
  type        = bool
  default     = true
  description = "Whether to create the RDS instance."
}

variable "rds_username" {
  type        = string
  default     = "datafold"
  description = "Overrides the default RDS user name that is provisioned."
}

variable "rds_password_override" {
  type        = string
  default     = null
  description = "Password override"
}

variable "rds_identifier" {
  type        = string
  default     = ""
  description = "Name of the RDS instance"
}

variable "rds_instance" {
  type        = string
  default     = "db.t3.medium"
  description = <<-EOT
    EC2 insance type for PostgreSQL RDS database.
    Available instance groups: t3, m4, m5, r6i, m6i
    Available instance classes: medium and higher.
  EOT
  validation {
    condition     = can(regex("^db\\.(t3|m4|m5|r6i|m6i)\\..+$", var.rds_instance))
    error_message = "Instance type for rds is not valid."
  }
}

variable "rds_allocated_storage" {
  type        = number
  default     = 20
  description = "The size of RDS allocated storage in GB"
}

variable "rds_max_allocated_storage" {
  type        = number
  default     = 100
  description = "The upper limit the database can grow in GB"
}

variable "rds_backups_replication_target_region" {
  type        = string
  default     = null
  description = "RDS backup replication target region"
}

variable "rds_backups_replication_retention_period" {
  type        = number
  default     = 14
  description = "RDS backup replication retention period"
}

variable "rds_maintenance_window" {
  type        = string
  default     = "Mon:00:00-Mon:03:00"
  description = "RDS maintenance window"
}

variable "rds_backup_window" {
  type        = string
  default     = "03:00-06:00"
  description = "RDS backup window"
}

variable "rds_multi_az" {
  type        = bool
  default     = false
  description = "RDS instance in multiple AZ's"
}

variable "create_rds_kms_key" {
  type        = bool
  default     = true
  description = "Set to true to create a separate KMS key (Recommended)."
}

variable "rds_kms_key_alias" {
  type        = string
  default     = "datafold-rds"
  description = "RDS KMS key alias."
}

variable "use_default_rds_kms_key" {
  type        = bool
  default     = false
  description = "Flag weither or not to use the default RDS KMS encryption key. Not recommended."
}

variable "database_name" {
  type        = string
  default     = "datafold"
  description = "RDS database name"
}

variable "db_subnet_group_name" {
  type        = string
  default     = ""
  description = "The specific subnet group name to use"
}

variable "db_parameter_group_name" {
  type        = string
  default     = ""
  description = "The specific parameter group name to associate"
}

variable "rds_ro_username" {
  type        = string
  default     = "datafold_ro"
  description = "RDS read-only user name (not currently used)."
}

variable "rds_version" {
  type        = string
  default     = "15.5"
  description = "Postgres RDS version to use."
}

variable "rds_port" {
  type        = number
  default     = 5432
  description = "The port the RDS database should be listening on."
}

variable "rds_param_group_family" {
  type        = string
  default     = "postgres15"
  description = "The DB parameter group family to use"
}

variable "apply_major_upgrade" {
  type        = bool
  default     = false
  description = "Sets the flag to allow AWS to apply major upgrade on the maintenance plan schedule."
}

variable "rds_performance_insights_enabled" {
  type        = bool
  default     = false
  description = "RDS performance insights enabled or not"
}

variable "rds_monitoring_role_arn" {
  type        = string
  description = "The IAM role allowed to send RDS metrics to cloudwatch"
  default     = null
}

variable "db_extra_parameters" {
  type        = list(any)
  default     = []
  description = "List of map of extra variables to apply to the RDS database parameter group"
}

variable "rds_copy_tags_to_snapshot" {
  type        = bool
  default     = false
  description = "To copy tags to snapshot or not"
}

variable "rds_performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "RDS performance insights retention period"
}

variable "rds_auto_minor_version_upgrade" {
  type        = bool
  default     = false
  description = "Sets a flag to upgrade automatically all minor versions"
}

variable "rds_monitoring_interval" {
  type        = number
  default     = 0
  description = "RDS monitoring interval"
}

#  ┏━╸╻  ╻┏━╸╻┏ ╻ ╻┏━┓╻ ╻┏━┓┏━╸
#  ┃  ┃  ┃┃  ┣┻┓┣━┫┃ ┃┃ ┃┗━┓┣╸
#  ┗━╸┗━╸╹┗━╸╹ ╹╹ ╹┗━┛┗━┛┗━┛┗━╸

variable "clickhouse_s3_bucket" {
  type        = string
  default     = "clickhouse-backups-abcguo23"
  description = "Bucket where clickhouse backups are stored"
}

variable "clickhouse_data_size" {
  type        = number
  default     = 40
  description = "EBS volume size for clickhouse data in GB"
}

variable "clickhouse_logs_size" {
  type        = number
  default     = 40
  description = "EBS volume size for clickhouse logs in GB"
}

variable "ebs_type" {
  type        = string
  default     = "gp3"
  description = "Type for all EBS volumes"
}

variable "ch_data_ebs_iops" {
  type        = number
  default     = 3000
  description = "IOPS of EBS volume"
}

variable "ch_data_ebs_throughput" {
  type        = number
  default     = 1000
  description = "Throughput of EBS volume"
}

variable "ch_logs_ebs_iops" {
  type        = number
  default     = 3000
  description = "IOPS of EBS volume"
}

variable "ch_logs_ebs_throughput" {
  type        = number
  default     = 250
  description = "Throughput of EBS volume"
}

variable "s3_backup_bucket_name_override" {
  type        = string
  default     = ""
  description = "Bucket name override."
}

variable "backup_lifecycle_expiration_days" {
  type        = number
  default     = 6
  description = "Number of days after which clickhouse backup objects will expire and be deleted."
}

# ┏━┓┏━╸╺┳┓╻┏━┓
# ┣┳┛┣╸  ┃┃┃┗━┓
# ╹┗╸┗━╸╺┻┛╹┗━┛

variable "redis_ebs_iops" {
  type        = number
  default     = 3000
  description = "IOPS of EBS redis volume"
}

variable "redis_ebs_throughput" {
  type        = number
  default     = 125
  description = "Throughput of EBS redis volume"
}

# ┏━╸╻┏ ┏━┓
# ┣╸ ┣┻┓┗━┓
# ┗━╸╹ ╹┗━┛

variable "k8s_module_version" {
  type        = string
  default     = "~> 19.7"
  description = "EKS terraform module version"
}

variable "k8s_cluster_version" {
  type        = string
  default     = "1.33"
  description = "Ref. https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html"
}

variable "self_managed_node_grp_instance_type" {
  type        = string
  default     = "THe instance type for the self managed node group."
  description = "Ref. https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt"
}

variable "self_managed_node_grps" {
  type        = any
  default     = {}
  description = "Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/self-managed-node-group"
}

variable "managed_node_grp1" {
  type        = any
  description = "Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group"
}

variable "managed_node_grp2" {
  type        = any
  default     = null
  description = "Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group"
}

variable "managed_node_grp3" {
  type        = any
  default     = null
  description = "Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group"
}

variable "managed_node_grp4" {
  type        = any
  default     = null
  description = "Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group"
}

variable "managed_node_grp5" {
  type        = any
  default     = null
  description = "Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group"
}

variable "managed_node_grp6" {
  type        = any
  default     = null
  description = "Ref. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group"
}

variable "default_node_disk_size" {
  type        = number
  default     = 40
  description = "Disk size for a node in GB"
}

variable "tags" {
  type        = any
  default     = {}
  description = "Tags to apply to the general module"
}

variable "k8s_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDRs that are allowed to connect to the EKS control plane"
}

variable "k8s_api_access_roles" {
  type        = set(string)
  default     = []
  description = "Set of roles that are allowed to access the EKS API"
}

# ┏━┓┏━┓╻╻ ╻┏━┓╺┳╸┏━╸   ┏━┓┏━╸┏━╸┏━╸┏━┓┏━┓
# ┣━┛┣┳┛┃┃┏┛┣━┫ ┃ ┣╸    ┣━┫┃  ┃  ┣╸ ┗━┓┗━┓
# ╹  ╹┗╸╹┗┛ ╹ ╹ ╹ ┗━╸╺━╸╹ ╹┗━╸┗━╸┗━╸┗━┛┗━┛

variable "deploy_private_access" {
  type        = bool
  default     = false
  description = "Determines that the cluster should be 100% private"
}

variable "allowed_principals" {
  type        = list(string)
  default     = []
  description = "List of allowed principals allowed to connect to this endpoint."
}

variable "vpn_cidr" {
  type        = string
  description = "CIDR range for administrative access"
  default     = ""
}

# ┏┓ ┏━╸╺┳┓┏━┓┏━┓┏━╸╻┏
# ┣┻┓┣╸  ┃┃┣┳┛┃ ┃┃  ┣┻┓
# ┗━┛┗━╸╺┻┛╹┗╸┗━┛┗━╸╹ ╹

variable "k8s_access_bedrock" {
  type        = bool
  default     = false
  description = "Allow cluster to access bedrock in this region"
}

variable "service_account_prefix" {
  type        = string
  default     = ""
  description = "Prefix for service account names to match Helm chart naming (e.g., 'datafold-' for 'datafold-server', or '' for no prefix)"
}

# ┏━╸╻╺┳╸╻ ╻╻ ╻┏┓    ┏━┓┏━╸╻ ╻┏━╸┏━┓┏━┓┏━╸   ┏━┓┏━┓┏━┓╻ ╻╻ ╻
# ┃╺┓┃ ┃ ┣━┫┃ ┃┣┻┓   ┣┳┛┣╸ ┃┏┛┣╸ ┣┳┛┗━┓┣╸    ┣━┛┣┳┛┃ ┃┏╋┛┗┳┛
# ┗━┛╹ ╹ ╹ ╹┗━┛┗━┛   ╹┗╸┗━╸┗┛ ┗━╸╹┗╸┗━┛┗━╸   ╹  ╹┗╸┗━┛╹ ╹ ╹

variable "deploy_github_reverse_proxy" {
  type        = bool
  default     = false
  description = "Determines that the github reverse proxy should be deployed"
}

variable "github_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDRs that are allowed to connect to the github reverse proxy"
}

variable "monitor_lambda_datadog" {
  description = "Whether to monitor the Lambda with Datadog"
  type        = bool
  default     = false
}

variable "datadog_api_key" {
  description = "The API key for Datadog"
  type        = string
  default     = ""
  sensitive   = true
}

# ╻ ╻┏━┓┏━╸   ┏━┓┏━╸┏━╸┏━┓╻┏┓╻┏━╸
# ┃┏┛┣━┛┃     ┣━┛┣╸ ┣╸ ┣┳┛┃┃┗┫┃╺┓
# ┗┛ ╹  ┗━╸   ╹  ┗━╸┗━╸╹┗╸╹╹ ╹┗━┛

variable "deploy_vpc_peering" {
  type        = bool
  default     = false
  description = "Determines that the VPC peering should be deployed"
}

variable "peer_vpc_id" {
  type        = string
  default     = ""
  description = "The VPC ID to peer with"
}

variable "peer_vpc_cidr_block" {
  type        = string
  default     = ""
  description = "The CIDR block of the peer VPC"
}

variable "peer_vpc_additional_whitelisted_ingress_cidrs" {
  type        = set(string)
  default     = []
  description = "List of CIDRs that can pass through the load balancer"
}

variable "peer_vpc_owner_id" {
  type        = string
  default     = ""
  description = "The AWS account ID of the owner of the peer VPC"
}

variable "peer_region" {
  type        = string
  default     = ""
  description = "The region of the peer VPC"
}

