#  ╻ ╻┏━┓┏━╸
#  ┃┏┛┣━┛┃
#  ┗┛ ╹  ┗━╸

locals {
  azs = coalescelist(
    var.provider_azs,
    sort(data.aws_availability_zones.available.names)
  )
  vpc_id = coalesce(
    one(module.vpc[*].vpc_id),
    one(data.aws_vpc.this[*].id)
  )
  vpc_public_subnets = coalesce(
    one(module.vpc[*].public_subnets),
    one(data.aws_subnet.this[*][*].cidr_block)
  )
  vpc_private_subnets = coalesce(
    one(module.vpc[*].private_subnets),
    one(data.aws_subnet.this[*][*].cidr_block)
  )
}

#  ┏┓╻┏━╸╻ ╻   ╻ ╻┏━┓┏━╸
#  ┃┗┫┣╸ ┃╻┃   ┃┏┛┣━┛┃
#  ╹ ╹┗━╸┗┻┛   ┗┛ ╹  ┗━╸

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_eip" "nat_gateway" {
  count = var.nat_gateway_public_ip != "" ? 0 : 1
  vpc   = true

  tags = {
    Name = "${var.deployment_name}-nat-gateway"
  }
}

data "aws_eip" "nat_gateway" {
  count     = var.nat_gateway_public_ip != "" ? 1 : 0
  public_ip = var.nat_gateway_public_ip
}

# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
module "vpc" {
  count = var.vpc_id == "" ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.deployment_name
  cidr = var.vpc_cidr

  azs = local.azs

  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  map_public_ip_on_launch = true

  manage_default_network_acl           = false
  manage_default_security_group        = false
  manage_default_route_table           = true
  default_route_table_name             = var.deployment_name
  default_route_table_tags             = { DefaultRouteTable = true }
  default_route_table_propagating_vgws = var.vpc_propagating_vgws
  propagate_private_route_tables_vgw   = var.propagate_private_route_tables_vgw
  propagate_public_route_tables_vgw    = var.propagate_public_route_tables_vgw
  vpn_gateway_id                       = var.vpc_vpn_gateway_id

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
  reuse_nat_ips          = true
  external_nat_ip_ids = [
    try(
      resource.aws_eip.nat_gateway[0].id,
      data.aws_eip.nat_gateway[0].id
    )
  ]

  dhcp_options_domain_name         = var.dhcp_options_domain_name
  dhcp_options_domain_name_servers = var.dhcp_options_domain_name_servers
  enable_dhcp_options              = var.enable_dhcp_options
  dhcp_options_tags                = var.dhcp_options_tags

  # tags
  private_subnet_tags = var.private_subnet_tags
  public_subnet_tags  = var.public_subnet_tags
  vpc_tags            = var.vpc_tags

  depends_on = [
    resource.aws_eip.nat_gateway[0]
  ]
}

#  ┏━╸╻ ╻╻┏━┓╺┳╸╻┏┓╻┏━╸   ╻ ╻┏━┓┏━╸
#  ┣╸ ┏╋┛┃┗━┓ ┃ ┃┃┗┫┃╺┓   ┃┏┛┣━┛┃
#  ┗━╸╹ ╹╹┗━┛ ╹ ╹╹ ╹┗━┛   ┗┛ ╹  ┗━╸

# This resource is intended to ensure that VPC with provided ID exists
data "aws_vpc" "this" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnets" "this" {
  count = var.vpc_id != "" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "this" {
  count = var.vpc_id != "" ? length(one(data.aws_subnets.this[*].ids)) : 0
  id    = one(data.aws_subnets.this[*].ids[count.index])
}

data "aws_vpc" "ensured_vpc" {
  id = local.vpc_id
}

#  ╻ ╻┏━┓┏━╸   ┏━╸╻  ┏━┓╻ ╻   ╻  ┏━┓┏━╸┏━┓
#  ┃┏┛┣━┛┃     ┣╸ ┃  ┃ ┃┃╻┃   ┃  ┃ ┃┃╺┓┗━┓
#  ┗┛ ╹  ┗━╸   ╹  ┗━╸┗━┛┗┻┛   ┗━╸┗━┛┗━┛┗━┛

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.deploy_vpc_flow_logs ? 1 : 0
  name  = "${var.deployment_name}-vpc-flow-logs-cw-log-group"
}

resource "aws_flow_log" "this" {
  count           = var.deploy_vpc_flow_logs ? 1 : 0
  iam_role_arn    = one(aws_iam_role.vpc_flow_logs[*].arn)
  log_destination = one(aws_cloudwatch_log_group.vpc_flow_logs[*].arn)
  traffic_type    = "ALL"
  vpc_id          = local.vpc_id
}
