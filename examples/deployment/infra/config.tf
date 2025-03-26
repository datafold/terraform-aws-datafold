resource "local_file" "infra_config" {
  filename = "${path.module}/../application/infra.dec.yaml"
  content = templatefile(
    "${path.module}/../templates/datafold/infra_settings.tpl",
    {
      aws_target_group_arn           = module.aws[0].target_group_arn,
      clickhouse_access_key          = module.aws[0].clickhouse_access_key,
      clickhouse_backup_sa           = "",
      clickhouse_data_size           = module.aws[0].clickhouse_data_size,
      clickhouse_data_volume_id      = module.aws[0].clickhouse_data_volume_id,
      clickhouse_gcs_bucket          = "",
      clickhouse_logs_size           = module.aws[0].clickhouse_logs_size,
      clickhouse_log_volume_id       = module.aws[0].clickhouse_logs_volume_id,
      clickhouse_s3_bucket           = module.aws[0].clickhouse_s3_bucket,
      clickhouse_s3_region           = module.aws[0].clickhouse_s3_region,
      clickhouse_secret_key          = module.aws[0].clickhouse_secret_key,
      clickhouse_azblob_account_name = "",
      clickhouse_azblob_account_key  = "",
      clickhouse_azblob_container    = "",
      cloud_provider                 = module.aws[0].cloud_provider,
      cluster_name                   = module.aws[0].cluster_name,
      gcp_neg_name                   = "",
      load_balancer_ips              = jsondecode(module.aws[0].load_balancer_ips),
      load_balancer_controller_arn   = module.aws[0].k8s_load_balancer_controller_role_arn,
      cluster_scaler_role_arn        = module.aws[0].cluster_scaler_role_arn,
      postgres_database              = local.database_name,
      postgres_password              = module.aws[0].postgres_password,
      postgres_port                  = module.aws[0].postgres_port,
      postgres_server                = module.aws[0].postgres_host,
      postgres_user                  = module.aws[0].postgres_username,
      redis_data_size                = module.aws[0].redis_data_size,
      redis_data_volume_id           = module.aws[0].redis_data_volume_id,
      server_name                    = module.aws[0].domain_name,
      vpc_cidr                       = module.aws[0].vpc_cidr,

      # service accounts vars
      dfshell_role_arn                           = module.aws[0].dfshell_role_arn,
      dfshell_service_account_name               = module.aws[0].dfshell_service_account_name,
      worker_portal_role_arn                     = module.aws[0].worker_portal_role_arn,
      worker_portal_service_account_name         = module.aws[0].worker_portal_service_account_name,
      operator_role_arn                          = module.aws[0].operator_role_arn,
      operator_service_account_name              = module.aws[0].operator_service_account_name,
      server_role_arn                            = module.aws[0].server_role_arn,
      server_service_account_name                = module.aws[0].server_service_account_name,
      scheduler_role_arn                         = module.aws[0].scheduler_role_arn,
      scheduler_service_account_name             = module.aws[0].scheduler_service_account_name,
      worker_role_arn                            = module.aws[0].worker_role_arn,
      worker_service_account_name                = module.aws[0].worker_service_account_name,
      worker_catalog_role_arn                    = module.aws[0].worker_catalog_role_arn,
      worker_catalog_service_account_name        = module.aws[0].worker_catalog_service_account_name,
      worker_interactive_role_arn                = module.aws[0].worker_interactive_role_arn,
      worker_interactive_service_account_name    = module.aws[0].worker_interactive_service_account_name,
      worker_singletons_role_arn                 = module.aws[0].worker_singletons_role_arn,
      worker_singletons_service_account_name     = module.aws[0].worker_singletons_service_account_name,
      worker_lineage_role_arn                    = module.aws[0].worker_lineage_role_arn,
      worker_lineage_service_account_name        = module.aws[0].worker_lineage_service_account_name,
      worker_monitor_role_arn                    = module.aws[0].worker_monitor_role_arn,
      worker_monitor_service_account_name        = module.aws[0].worker_monitor_service_account_name,
      storage_worker_role_arn                    = module.aws[0].storage_worker_role_arn,
      storage_worker_service_account_name        = module.aws[0].storage_worker_service_account_name,
    }
  )

  provisioner "local-exec" {
    environment = {
      "AWS_PROFILE" : "${local.kms_profile}",
      "SOPS_KMS_ARN" : "${local.kms_key}"
    }
    command = "sops --aws-profile ${local.kms_profile} --output '${path.module}/../application/infra.yaml' -e '${path.module}/../application/infra.dec.yaml'"
  }

  depends_on = [
    module.aws[0]
  ]
}
