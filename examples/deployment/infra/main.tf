#  ┏┳┓┏━┓╻┏┓╻
#  ┃┃┃┣━┫┃┃┗┫
#  ╹ ╹╹ ╹╹╹ ╹

locals {
  # For limited public access
  proxy_host_cidrs = [
    "1.2.3.4/32"
  ]
  # For private access
  # vpn_cidr               = "1.2.3.4/24"
  # vpn_allowed_principals = ["arn:aws:iam::1234567890:root"]

  database_name  = module.aws[0].postgres_database_name
}

#  ┏━┓╻ ╻┏━┓
#  ┣━┫┃╻┃┗━┓
#  ╹ ╹┗┻┛┗━┛

module "aws" {
  source  = "datafold/datafold/aws"
  version = "1.7.2"

  providers = {
    aws = aws
  }

  # Common
  deployment_name = local.deployment_name
  environment     = local.environment

  # Provider
  provider_region = local.provider_region

  # Load Balancer
  # Either finds the pre-created certificate or creates a new one
  alb_certificate_domain = "datafold.acme.com"
  create_ssl_cert        = false
  backend_app_port       = var.backend_app_port

  # Set this to true after the initial deploy.
  # it is used to resolve data block dependencies on resources that
  # don't exist yet.
  initial_apply_complete = false

  # Security Groups / Virtual Private Cloud
  whitelisted_ingress_cidrs = ["0.0.0.0/0"]
  whitelisted_egress_cidrs = concat(
    ["0.0.0.0/0"],
    local.github_cidrs
  )
  deploy_vpc_flow_logs = true

  # Clickhouse
  ch_data_ebs_iops       = 3000
  ch_data_ebs_throughput = 125
  clickhouse_data_size   = 50

  # Database
  use_default_rds_kms_key   = true
  apply_major_upgrade       = false
  rds_max_allocated_storage = 100
  rds_version               = "15.5"
  rds_param_group_family    = "postgres15"

  # K8S
  k8s_public_access_cidrs = local.proxy_host_cidrs

  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v19.7.0/docs/compute_resources.md
  managed_node_grp_default = ["c6i.4xlarge"]

  managed_node_grp1 = {
    min_size     = 1
    max_size     = 2
    desired_size = 1

    instance_types  = ["r5a.2xlarge"]
    capacity_type   = "ON_DEMAND"
    use_name_prefix = false
    name            = "datafold-nodegroup"

    force_update_version = true
    update_config        = { "max_unavailable_percentage" : 50 }
  }

  # For larger deployments, you can configure a second node pool "managed_node_grp2"

  # To enable private access
  #  deploy_private_access = true
  #  allowed_principals = local.vpn_allowed_principals
  #  vpn_cidr = local.vpn_cidr
}

