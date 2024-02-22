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
