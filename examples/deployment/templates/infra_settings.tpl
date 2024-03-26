clickhouse:
  config:
    gcs_bucket: ${clickhouse_gcs_bucket}
    s3_bucket: ${clickhouse_s3_bucket}
    s3_region: ${clickhouse_s3_region}
  storage:
    dataSize: ${clickhouse_data_size}
    dataVolumeId: ${clickhouse_data_volume_id}
    logSize: ${clickhouse_logs_size}
    logVolumeId: ${clickhouse_log_volume_id}
  secrets:
    access_key: ${clickhouse_access_key}
    clickhouse_backup_sa: ${clickhouse_backup_sa}
    secret_key: ${clickhouse_secret_key}

redis:
  storage:
    dataSize: ${redis_data_size}
    dataVolumeId: ${redis_data_volume_id}

global:
  awsTargetGroupArn: ${aws_target_group_arn}
  loadBalancerControllerArn: ${load_balancer_controller_arn}
  clusterScalerRoleArn: ${cluster_scaler_role_arn}
  cloudProvider: ${cloud_provider}
  clusterName: ${cluster_name}
  nginx:
    gcpNegName: ${gcp_neg_name}
  postgres:
    server: ${postgres_server}
  serverName: ${server_name}
  vpcCidr: ${vpc_cidr}

nginx:
  service:
    loadBalancerIps: ${load_balancer_ips}

secrets:
  clickhouse:
    password: ${clickhouse_password}
  database:
    encryptionKey: "${db_encryption_key}"
  datadog:
    apiKey: ${dd_api_key}
    appKey: ${dd_app_key}
    applicationId: ${dd_application_id}
    clientToken: ${dd_client_token}
  freshpaint:
    avoToken: ${freshpaint_avo_token}
    backendToken: ${freshpaint_backend_token}
    frontendToken: ${freshpaint_frontend_token}
  mail:
    username: ${mail_username}
    password: ${mail_password}
  postgres:
    database: ${postgres_database}
    password: ${postgres_password}
    port: ${postgres_port}
    user: ${postgres_user}
  redis:
    password: ${redis_password}
