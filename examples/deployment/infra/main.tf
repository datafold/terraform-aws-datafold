#  ┏┳┓┏━┓╻┏┓╻
#  ┃┃┃┣━┫┃┃┗┫
#  ╹ ╹╹ ╹╹╹ ╹

locals {
  proxy_host_cidrs = [
    "1.2.3.4/32"
  ]
}

#  ┏━┓╻ ╻┏━┓
#  ┣━┫┃╻┃┗━┓
#  ╹ ╹┗┻┛┗━┛

module "aws" {
  count   = 1
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

  # Database
  use_default_rds_kms_key   = true
  apply_major_upgrade       = false
  rds_max_allocated_storage = 400

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
}

