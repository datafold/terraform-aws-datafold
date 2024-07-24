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
  postgres:
    database: ${postgres_database}
    password: ${postgres_password}
    port: ${postgres_port}
    user: ${postgres_user}
