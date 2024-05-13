#  ┏┳┓┏━┓╻┏┓╻
#  ┃┃┃┣━┫┃┃┗┫
#  ╹ ╹╹ ╹╹╹ ╹

#  ┏━┓╻ ╻┏━┓
#  ┣━┫┃╻┃┗━┓
#  ╹ ╹┗┻┛┗━┛

module "aws" {
  count   = 1
  source  = "datafold/datafold/aws"
  version = "1.1.2"

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
  ebs_iops       = 3000
  ebs_throughput = 125

  # Database
  use_default_rds_kms_key = true
  apply_major_upgrade     = false

  # K8S

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
  }

  aws_auth_users = []

  vpce_details = {"ssh": {
    vpces_service_name  = "com.amazonaws.vpce.us-east-1.vpce-svc-abcdef"
    # subnet_id           = "subnet-abcdef123456"  # optional
    # private_dns_enabled = false  # optional
    input_rules = [{
       description = "Allow SSH traffic through"
       from_port   = 22
       to_port     = 22
       protocol    = "TCP"
       cidr_blocks = "10.0.0.0/16"
    }]
    output_rules = [{
       description = "Allow all egress TCP"
       from_port   = 0
       to_port     = 65535
       protocol    = "TCP"
       cidr_blocks = "0.0.0.0/0"
    },{
       description = "Allow all egress UDP"
       from_port   = 0
       to_port     = 65535
       protocol    = "UDP"
       cidr_blocks = "0.0.0.0/0"
    }]
  }}
}

