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
  sg_tags                            = var.sg_tags
  vpce_details                       = var.vpce_details
  vpc_exclude_az_ids                 = var.vpc_exclude_az_ids
}

locals {
  vpc_id              = module.networking.vpc_id
  vpc_public_subnets  = module.networking.vpc_public_subnets
  vpc_private_subnets = module.networking.vpc_private_subnets
  azs                 = module.networking.azs
  vpc_cidr            = module.networking.vpc_cidr
}

module "security" {
  source = "./modules/security"

  deployment_name           = var.deployment_name
  vpc_id                    = local.vpc_id
  vpc_cidr                  = local.vpc_cidr
  whitelisted_ingress_cidrs = var.whitelisted_ingress_cidrs
  whitelisted_egress_cidrs  = var.whitelisted_egress_cidrs
  ingress_enable_http_sg    = var.ingress_enable_http_sg
  dns_egress_cidrs          = var.dns_egress_cidrs
  backend_app_port          = var.backend_app_port
  sg_tags                   = var.sg_tags
  lb_deploy_nlb             = var.lb_deploy_nlb
}

locals {
  lb_security_group_id = module.security.lb_security_group_id
  db_security_group_id = module.security.db_security_group_id
  vpces_sec_group_id   = module.security.vpces_sec_group_id
}

module "load_balancer" {
  source = "./modules/load_balancer"

  deployment_name        = var.deployment_name
  vpc_id                 = local.vpc_id
  vpc_cidr               = local.vpc_cidr
  vpc_subnets            = var.lb_internal ? local.vpc_private_subnets : local.vpc_public_subnets
  lb_nlb_subnets         = var.lb_nlb_internal ? local.vpc_private_subnets : local.vpc_public_subnets
  security_group_id      = local.lb_security_group_id
  create_ssl_cert        = var.create_ssl_cert
  alb_certificate_domain = var.alb_certificate_domain
  lb_internal            = var.lb_internal
  lb_idle_timeout        = var.lb_idle_timeout
  backend_app_port       = var.backend_app_port
  lb_deletion_protection = var.lb_deletion_protection
  lb_name_override       = var.lb_name_override
  lb_access_logs         = var.lb_access_logs
  lb_deploy_nlb          = var.lb_deploy_nlb
  lb_vpces_details       = var.lb_vpces_details
  initial_apply_complete = var.initial_apply_complete

  vpces_security_group_id = local.vpces_sec_group_id
}

locals {
  default_node_pool = merge(
    {
      subnet_ids = [local.vpc_private_subnets[var.private_subnet_index]]
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
    }, var.managed_node_grp1)
  second_node_pool = merge(
    {
      subnet_ids = [local.vpc_private_subnets[var.private_subnet_index]]
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
    }, var.managed_node_grp2)
  third_node_pool = merge(
    {
      subnet_ids = [local.vpc_private_subnets[var.private_subnet_index]]
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
    }, var.managed_node_grp3)
  managed_node_groups = merge(
    {"${var.deployment_name}-k8s": local.default_node_pool},
    var.managed_node_grp2 != null ? {"${var.deployment_name}-k8s-two" : local.second_node_pool} : {},
    var.managed_node_grp3 != null ? {"${var.deployment_name}-k8s-three" : local.third_node_pool} : {}
  )
}

module "eks" {
  source = "./modules/eks"

  deployment_name                     = var.deployment_name
  k8s_vpc                             = local.vpc_id
  # https://aws.github.io/aws-eks-best-practices/networking/subnets/
  k8s_subnets                         = local.vpc_private_subnets
  k8s_control_subnets                 = []
  k8s_module_version                  = var.k8s_module_version
  k8s_cluster_version                 = var.k8s_cluster_version
  lb_security_group_id                = local.lb_security_group_id
  db_security_group_id                = local.db_security_group_id
  self_managed_node_grp_instance_type = var.self_managed_node_grp_instance_type
  self_managed_node_grp_default       = var.self_managed_node_grp_default
  self_managed_node_grps              = var.self_managed_node_grps
  managed_node_grp_default            = var.managed_node_grp_default
  managed_node_grps                   = local.managed_node_groups
  k8s_api_access_roles                = var.k8s_api_access_roles

  tags                                = var.tags
  backend_app_port                    = var.backend_app_port
  rds_port                            = var.rds_port
  k8s_public_access_cidrs             = var.k8s_public_access_cidrs

  k8s_access_bedrock                  = var.k8s_access_bedrock
}

locals {
  cluster_name        = module.eks.cluster_name
  control_plane_sg_id = module.eks.control_plane_security_group_id
}

module "database" {
  source = "./modules/database"

  deployment_name                          = var.deployment_name
  rds_identifier                           = var.rds_identifier
  provider_region                          = var.provider_region
  vpc_private_subnets                      = local.vpc_private_subnets
  rds_username                             = var.rds_username
  rds_password_override                    = var.rds_password_override
  rds_instance                             = var.rds_instance
  rds_allocated_storage                    = var.rds_allocated_storage
  rds_max_allocated_storage                = var.rds_max_allocated_storage
  rds_backups_replication_target_region    = var.rds_backups_replication_target_region
  rds_backups_replication_retention_period = var.rds_backups_replication_retention_period
  rds_backup_window                        = var.rds_backup_window
  rds_maintenance_window                   = var.rds_maintenance_window
  create_rds_kms_key                       = var.create_rds_kms_key
  rds_kms_key_alias                        = var.rds_kms_key_alias
  use_default_rds_kms_key                  = var.use_default_rds_kms_key
  database_name                            = var.database_name
  db_subnet_group_name                     = var.db_subnet_group_name
  db_parameter_group_name                  = var.db_parameter_group_name
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
  rds_multi_az                             = var.rds_multi_az
  rds_copy_tags_to_snapshot                = var.rds_copy_tags_to_snapshot
  rds_performance_insights_enabled         = var.rds_performance_insights_enabled
  rds_performance_insights_retention_period= var.rds_performance_insights_retention_period
  rds_monitoring_role_arn                  = var.rds_monitoring_role_arn
  rds_auto_minor_version_upgrade           = var.rds_auto_minor_version_upgrade
  rds_monitoring_interval                  = var.rds_monitoring_interval
}

module "clickhouse_backup" {
  source = "./modules/clickhouse_backup"

  deployment_name                = var.deployment_name
  clickhouse_s3_bucket           = var.clickhouse_s3_bucket
  s3_clickhouse_backup_tags      = var.s3_clickhouse_backup_tags
  s3_backup_bucket_name_override = var.s3_backup_bucket_name_override
}

module "private_access" {
  count = var.deploy_private_access ? 1 : 0
  source = "./modules/private_access"

  allowed_principals  = var.allowed_principals
  deployment_name     = var.deployment_name
  vpc_id              = local.vpc_id
  vpc_private_subnets = [local.vpc_private_subnets[0]]
  eks_cluster_name    = local.cluster_name
  tags                = var.tags
  control_plane_sg_id = local.control_plane_sg_id
  vpn_cidr            = var.vpn_cidr
}

resource "aws_ebs_volume" "clickhouse_data" {
  availability_zone = local.azs[var.az_index]
  size              = var.clickhouse_data_size
  encrypted         = true
  type              = var.ebs_type
  iops              = var.ebs_type != "gp2" ? var.ch_data_ebs_iops : null
  throughput        = var.ebs_type != "gp2" ? var.ch_data_ebs_throughput : null

  tags = merge({
    Name = "${var.deployment_name}-clickhouse-data"
  }, var.ebs_extra_tags)
}

resource "aws_ebs_volume" "clickhouse_logs" {
  availability_zone = local.azs[var.az_index]
  size              = var.clickhouse_logs_size
  encrypted         = true
  type              = var.ebs_type
  iops              = var.ebs_type != "gp2" ? var.ch_logs_ebs_iops : null
  throughput        = var.ebs_type != "gp2" ? var.ch_logs_ebs_throughput : null

  tags = {
    Name = "${var.deployment_name}-clickhouse-logs"
  }
}

resource "aws_ebs_volume" "redis_data" {
  availability_zone = local.azs[var.az_index]
  size              = var.redis_data_size
  encrypted         = true
  type              = var.ebs_type
  iops              = var.ebs_type != "gp2" ? var.redis_ebs_iops : null
  throughput        = var.ebs_type != "gp2" ? var.redis_ebs_throughput : null

  tags = {
    Name = "${var.deployment_name}-redis-data"
  }
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

module "github_reverse_proxy" {
  count = var.deploy_github_reverse_proxy ? 1 : 0

  source = "./modules/github_reverse_proxy"

  deployment_name          = var.deployment_name
  environment              = var.environment
  region                   = var.provider_region
  vpc_cidr                 = local.vpc_cidr
  vpc_id                   = local.vpc_id
  vpc_private_subnets      = local.vpc_private_subnets
  github_cidrs             = var.github_cidrs
  datadog_api_key          = var.datadog_api_key
  use_private_egress       = var.lb_internal

  private_system_endpoint  = module.load_balancer.load_balancer_dns
}

module "vpc_peering" {
  count = var.deploy_vpc_peering ? 1 : 0

  source = "./modules/vpc_peering"

  deployment_name                               = var.deployment_name
  vpc_id                                        = local.vpc_id
  vpc_subnets                                   = var.lb_internal ? local.vpc_private_subnets : local.vpc_public_subnets
  peer_vpc_id                                   = var.peer_vpc_id
  peer_region                                   = var.peer_region != "" ? var.peer_region : var.provider_region
  peer_owner_id                                 = var.peer_vpc_owner_id
  peer_vpc_cidr_block                           = var.peer_vpc_cidr_block
  peer_vpc_additional_whitelisted_ingress_cidrs = var.peer_vpc_additional_whitelisted_ingress_cidrs
  ingress_enable_http_sg                        = var.ingress_enable_http_sg

  lb_security_group_id       = module.security.lb_security_group_id
  vpc_main_route_table_id    = module.networking.vpc_main_route_table_id
  vpc_private_route_table_id = module.networking.vpc_private_route_table_id
  vpc_public_route_table_id  = module.networking.vpc_public_route_table_id
}

resource "null_resource" "deployment_check" {
  triggers = {
    initial_apply_complete = var.initial_apply_complete
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Get the load balancer IPs value
      LB_IPS="${module.load_balancer.load_balancer_ips}"

      echo $LB_IPS

      # Check if it's empty, null, or just "[]"
      if [ -z "$LB_IPS" ] || [ "$LB_IPS" = "[]" ] || [ "$LB_IPS" = "[\"\"]" ]|| [ "$LB_IPS" = "null" ]; then
        echo "\n\nERROR: Initial deployment complete. Set 'initial_apply_complete = true' to resolve load balancer IP dependencies.\n\n"
        exit 1
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
    quiet       = true
  }

  depends_on = [
    module.load_balancer
  ]
}
