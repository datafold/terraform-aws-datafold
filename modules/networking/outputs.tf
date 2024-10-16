output "vpc_id" {
  value = local.vpc_id
}

output "vpc_public_subnets" {
  value = local.vpc_public_subnets
}

output "vpc_private_subnets" {
  value = local.vpc_private_subnets
}

output "vpc_cidr" {
  value = data.aws_vpc.ensured_vpc.cidr_block
}

output "azs" {
  value = local.azs
}

output "vpc_main_route_table_id" {
  value = local.vpc_main_route_table_id
}

output "vpc_private_route_table_id" {
  value = local.vpc_private_route_table_id
}

output "vpc_public_route_table_id" {
  value = local.vpc_public_route_table_id
}
