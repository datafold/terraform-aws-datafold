module "networking" {
  source = "./modules/networking"

  vpc_id                             = var.vpc_id
  vpc_cidr                           = var.vpc_cidr
  vpc_private_subnets                = var.vpc_private_subnets
  vpc_public_subnets                 = var.vpc_public_subnets
  deploy_vpc_flow_logs               = var.deploy_vpc_flow_logs
  nat_gateway_public_ip              = var.nat_gateway_public_ip
  vpc_propagating_vgws               = var.vpc_propagating_vgws
  vpc_vpn_gateway_id                 = var.vpc_vpn_gateway_id
  propagate_intra_route_tables_vgw   = var.propagate_intra_route_tables_vgw
  propagate_private_route_tables_vgw = var.propagate_private_route_tables_vgw
  propagate_public_route_tables_vgw  = var.propagate_public_route_tables_vgw
  dhcp_options_domain_name           = var.dhcp_options_domain_name
  dhcp_options_domain_name_servers   = var.dhcp_options_domain_name_servers
  enable_dhcp_options                = var.enable_dhcp_options
  dhcp_options_tags                  = var.dhcp_options_tags
  provider_azs                       = var.provider_azs
  deployment_name                    = var.deployment_name
  private_subnet_tags                = var.private_subnet_tags
  public_subnet_tags                 = var.public_subnet_tags
  vpc_tags                           = var.vpc_tags
}

locals {
  vpc_id              = module.networking.vpc_id
  vpc_public_subnets  = module.networking.vpc_public_subnets
  vpc_private_subnets = module.networking.vpc_private_subnets
  azs                 = module.networking.azs
}

module "security" {
  source = "./modules/security"

  deployment_name           = var.deployment_name
  vpc_id                    = local.vpc_id
  vpc_cidr                  = var.vpc_cidr
  whitelisted_ingress_cidrs = var.whitelisted_ingress_cidrs
  whitelisted_egress_cidrs  = var.whitelisted_egress_cidrs
  ingress_enable_http_sg    = var.ingress_enable_http_sg
  dns_egress_cidrs          = var.dns_egress_cidrs
  backend_app_port          = var.backend_app_port
  sg_tags                   = var.sg_tags
}

locals {
  lb_security_group_id = module.security.lb_security_group_id
  db_security_group_id = module.security.db_security_group_id
}

module "load_balancer" {
  source = "./modules/load_balancer"

  deployment_name        = var.deployment_name
  vpc_id                 = local.vpc_id
  vpc_public_subnets     = local.vpc_public_subnets
  security_group_id      = local.lb_security_group_id
  create_ssl_cert        = var.create_ssl_cert
  alb_certificate_domain = var.alb_certificate_domain
  lb_internal            = var.lb_internal
  lb_idle_timeout        = var.lb_idle_timeout
  backend_app_port       = var.backend_app_port
}

module "eks" {
  source = "./modules/eks"

  deployment_name = var.deployment_name
  k8s_vpc         = local.vpc_id
  # https://aws.github.io/aws-eks-best-practices/networking/subnets/
  k8s_subnets                         = local.vpc_private_subnets
  k8s_control_subnets                 = []
  k8s_module_version                  = var.k8s_module_version
  k8s_cluster_version                 = var.k8s_cluster_version
  lb_security_group_id                = local.lb_security_group_id
  db_security_group_id                = local.db_security_group_id
  self_managed_node_grp_instance_type = var.self_managed_node_grp_instance_type
  self_managed_node_grp_default       = var.self_managed_node_grp_default
  self_managed_node_grp               = var.self_managed_node_grp
  managed_node_grp_default            = var.managed_node_grp_default
  managed_node_grp = {
    "${var.deployment_name}-k8s"      = merge(var.managed_node_grp,
      {
        subnet_ids = [local.vpc_private_subnets[0]]
        disk_size  = var.default_node_disk_size
        tags = {
            "k8s.io/cluster-autoscaler/enabled"                  = "true"
            "k8s.io/cluster-autoscaler/${var.deployment_name}"   = "owned"
            "k8s.io/cluster-autoscaler/node-template/label/role" = "${var.deployment_name}"
        }
        block_device_mappings = {
          xvda = {
            device_name = "/dev/xvda"
            ebs = {
              volume_size           = var.default_node_disk_size
              volume_type           = "gp3"
              iops                  = 3000
              throughput            = 125
              encrypted             = true
              delete_on_termination = true
            }
          }
        }
      })
  }
  create_aws_auth_configmap           = var.create_aws_auth_configmap
  manage_aws_auth_configmap           = var.manage_aws_auth_configmap
  aws_auth_users                      = var.aws_auth_users
  aws_auth_accounts                   = var.aws_auth_accounts
  tags                                = var.tags
  backend_app_port                    = var.backend_app_port
  rds_port                            = var.rds_port
}

module "database" {
  source = "./modules/database"

  deployment_name                          = var.deployment_name
  provider_region                          = var.provider_region
  vpc_private_subnets                      = local.vpc_private_subnets
  rds_username                             = var.rds_username
  rds_instance                             = var.rds_instance
  rds_allocated_storage                    = var.rds_allocated_storage
  rds_max_allocated_storage                = var.rds_max_allocated_storage
  rds_backups_replication_target_region    = var.rds_backups_replication_target_region
  rds_backups_replication_retention_period = var.rds_backups_replication_retention_period
  create_rds_kms_key                       = var.create_rds_kms_key
  rds_kms_key_alias                        = var.rds_kms_key_alias
  use_default_rds_kms_key                  = var.use_default_rds_kms_key
  database_name                            = var.database_name
  rds_ro_username                          = var.rds_ro_username
  rds_version                              = var.rds_version
  rds_port                                 = var.rds_port
  rds_param_group_family                   = var.rds_param_group_family
  apply_major_upgrade                      = var.apply_major_upgrade
  db_instance_tags                         = var.db_instance_tags
  db_parameter_group_tags                  = var.db_parameter_group_tags
  db_subnet_group_tags                     = var.db_subnet_group_tags
  rds_extra_tags                           = var.rds_extra_tags
  security_group_id                        = local.db_security_group_id
  db_extra_parameters                      = var.db_extra_parameters
}

module "clickhouse_backup" {
  source = "./modules/clickhouse_backup"

  deployment_name           = var.deployment_name
  clickhouse_s3_bucket      = var.clickhouse_s3_bucket
  s3_clickhouse_backup_tags = var.s3_clickhouse_backup_tags
}

resource "aws_ebs_volume" "clickhouse_data" {
  availability_zone = local.azs[0]
  size              = var.clickhouse_data_size
  encrypted         = true
  type              = var.ebs_type
  iops              = var.ebs_type != "gp2" ? var.ebs_iops : null
  throughput        = var.ebs_type != "gp2" ? var.ebs_throughput : null

  tags = merge({
    Name = "${var.deployment_name}-clickhouse-data"
  }, var.ebs_extra_tags)
}

resource "aws_ebs_volume" "clickhouse_logs" {
  availability_zone = local.azs[0]
  size              = var.clickhouse_logs_size
  encrypted         = true
  type              = var.ebs_type
  iops              = var.ebs_type != "gp2" ? var.ebs_iops : null
  throughput        = var.ebs_type != "gp2" ? var.ebs_throughput : null

  tags = merge({
    Name = "${var.deployment_name}-clickhouse-logs"
  }, var.ebs_extra_tags)
}

resource "aws_ebs_volume" "redis_data" {
  availability_zone = local.azs[0]
  size              = var.redis_data_size
  encrypted         = true
  type              = var.ebs_type
  iops              = var.ebs_type != "gp2" ? var.ebs_iops : null
  throughput        = var.ebs_type != "gp2" ? var.ebs_throughput : null

  tags = merge({
    Name = "${var.deployment_name}-redis-data"
  }, var.ebs_extra_tags)
}

resource "random_password" "clickhouse_password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  special          = false
}

resource "random_password" "redis_password" {
  length           = 12
  special          = false
}
