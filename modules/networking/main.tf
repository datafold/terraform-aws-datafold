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
    one(data.aws_subnets.public[*].ids)
  )
  vpc_private_subnets = coalesce(
    one(module.vpc[*].private_subnets),
    one(data.aws_subnets.private[*].ids)
  )
  vpc_main_route_table_id = data.aws_vpc.ensured_vpc.main_route_table_id
  vpc_private_route_table_id = one(data.aws_route_tables.ensured_private_subnet_route_table.ids)
  vpc_public_route_table_id = one(data.aws_route_tables.ensured_public_subnet_route_table.ids)
}

#  ┏┓╻┏━╸╻ ╻   ╻ ╻┏━┓┏━╸
#  ┃┗┫┣╸ ┃╻┃   ┃┏┛┣━┛┃
#  ╹ ╹┗━╸┗┻┛   ┗┛ ╹  ┗━╸

data "aws_availability_zones" "available" {
  state = "available"

  exclude_zone_ids = var.vpc_exclude_az_ids
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

data "aws_subnets" "public" {
  count = var.vpc_id != "" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = var.public_subnet_tags
}

data "aws_subnets" "private" {
  count = var.vpc_id != "" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = var.private_subnet_tags
}

data "aws_subnet" "this" {
  count = var.vpc_id != "" ? length(one(data.aws_subnets.public[*].ids)) : 0
  id    = one(data.aws_subnets.public[*].ids[count.index])
}

data "aws_vpc" "ensured_vpc" {
  id = local.vpc_id
}

data "aws_route_tables" "ensured_private_subnet_route_table" {
  vpc_id = local.vpc_id

  filter {
    name = "tag:Name"
    values = ["${var.deployment_name}-private"]
  }
}

data "aws_route_tables" "ensured_public_subnet_route_table" {
  vpc_id = local.vpc_id

  filter {
    name = "tag:Name"
    values = ["${var.deployment_name}-public"]
  }
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

# ╻ ╻┏━┓┏━╸┏━╸
# ┃┏┛┣━┛┃  ┣╸
# ┗┛ ╹  ┗━╸┗━╸

module "vpce_sg" {
  for_each = var.vpce_details

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.3.0"

  name   = "${var.deployment_name}-${each.key}"
  vpc_id = local.vpc_id

  ingress_with_cidr_blocks = each.value.input_rules
  egress_with_cidr_blocks  = each.value.output_rules

  tags = var.sg_tags
}

resource "aws_vpc_endpoint" "vpce" {
  for_each          = var.vpce_details

  vpc_id            = local.vpc_id
  service_name      = each.value.vpces_service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [
      module.vpce_sg[each.key].security_group_id,
  ]

  subnet_ids          = coalescelist(each.value.subnet_ids, local.vpc_private_subnets)
  private_dns_enabled = each.value.private_dns_enabled

  depends_on = [
    module.vpc,
    data.aws_subnet.this
  ]
}
