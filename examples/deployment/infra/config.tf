resource "local_file" "infra_config" {
  filename = "${path.module}/../application/infra.dec.yaml"
  content = templatefile(
    "${path.module}/../../../../../../templates/datafold/infra_settings.tpl",
    {
      aws_target_group_arn         = module.aws[0].target_group_arn,
      clickhouse_access_key        = module.aws[0].clickhouse_access_key,
      clickhouse_backup_sa         = "",
      clickhouse_data_size         = module.aws[0].clickhouse_data_size,
      clickhouse_data_volume_id    = module.aws[0].clickhouse_data_volume_id,
      clickhouse_gcs_bucket        = "",
      clickhouse_logs_size         = module.aws[0].clickhouse_logs_size,
      clickhouse_log_volume_id     = module.aws[0].clickhouse_logs_volume_id,
      clickhouse_s3_bucket         = module.aws[0].clickhouse_s3_bucket,
      clickhouse_s3_region         = module.aws[0].clickhouse_s3_region,
      clickhouse_secret_key        = module.aws[0].clickhouse_secret_key,
      cloud_provider               = module.aws[0].cloud_provider,
      cluster_name                 = module.aws[0].cluster_name,
      gcp_neg_name                 = "",
      load_balancer_ips            = module.aws[0].load_balancer_ips,
      load_balancer_controller_arn = module.aws[0].k8s_load_balancer_controller_role_arn,
      cluster_scaler_role_arn      = module.aws[0].cluster_scaler_role_arn,
      postgres_database            = local.database_name,
      postgres_password            = module.aws[0].postgres_password,
      postgres_port                = module.aws[0].postgres_port,
      postgres_server              = module.aws[0].postgres_host,
      postgres_user                = module.aws[0].postgres_username,
      redis_data_size              = module.aws[0].redis_data_size,
      redis_data_volume_id         = module.aws[0].redis_data_volume_id,
      server_name                  = module.aws[0].domain_name,
      vpc_cidr                     = module.aws[0].vpc_cidr,
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
