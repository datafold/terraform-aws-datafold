#  ┏┳┓┏━┓╻┏┓╻
#  ┃┃┃┣━┫┃┃┗┫
#  ╹ ╹╹ ╹╹╹ ╹


locals {
  database_name = module.aws.postgres_database_name
}

module "aws" {
  source  = "datafold/datafold/aws"
  version = "~> 1.14.7" # Always update this to latest version (see releases in repository)

  providers = {
    aws = aws
  }

  # Common
  deployment_name = local.deployment_name
  environment     = local.environment

  # Provider
  provider_region = local.provider_region

  # Load Balancer
  alb_certificate_domain = "datafold.example.com"
  create_ssl_cert        = true
  backend_app_port       = var.backend_app_port
  deploy_lb              = false # Load balancer disabled by default
  initial_apply_complete = true

  # Security Groups / Virtual Private Cloud
  whitelisted_ingress_cidrs = ["0.0.0.0/0"]
  whitelisted_egress_cidrs = concat(
    ["0.0.0.0/0"],
    local.github_cidrs
  )
  deploy_vpc_flow_logs = true

  # Clickhouse
  clickhouse_s3_bucket   = "clickhouse-backups-example"
  clickhouse_data_size   = 50
  ch_data_ebs_iops       = 3000
  ch_data_ebs_throughput = 125

  # Redis
  redis_data_size = 50

  # Database
  apply_major_upgrade       = false
  rds_max_allocated_storage = 100
  rds_version               = "17.5"
  rds_param_group_family    = "postgres17"

  # K8S
  k8s_public_access_cidrs = local.proxy_host_cidrs
  k8s_cluster_version     = local.k8s_version

  managed_node_grp1 = {
    min_size     = 1
    max_size     = 2
    desired_size = 1

    instance_types  = ["r6a.2xlarge"]
    capacity_type   = "ON_DEMAND"
    use_name_prefix = false
    name            = "datafold-nodegroup"

    force_update_version = true
    update_config        = { "max_unavailable_percentage" : 50 }
  }

  # For larger deployments, you can configure a second node pool "managed_node_grp2"
  # managed_node_grp2 = {
  #   min_size     = 0
  #   max_size     = 1
  #   desired_size = 0
  #
  #   instance_types  = ["m5a.large"]
  #   capacity_type   = "ON_DEMAND"
  #   use_name_prefix = false
  #   name            = "datafold-ng-small"
  #
  #   force_update_version = true
  #   update_config        = { "max_unavailable_percentage" : 50 }
  # }

  # To enable private access
  # deploy_private_access = true
  # allowed_principals    = local.vpn_allowed_principals
  # vpn_cidr              = local.vpn_cidr
}

