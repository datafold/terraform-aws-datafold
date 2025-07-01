clickhouse:
  config:
    gcs_bucket: ${clickhouse_gcs_bucket}
    s3_bucket: ${clickhouse_s3_bucket}
    s3_region: ${clickhouse_s3_region}
    s3_backup_role: ${clickhouse_s3_backup_role}
    azblob_account_name: ${clickhouse_azblob_account_name}
    azblob_container: ${clickhouse_azblob_container}
  storage:
    dataSize: ${clickhouse_data_size}
    dataVolumeId: ${clickhouse_data_volume_id}
    logSize: ${clickhouse_logs_size}
    logVolumeId: ${clickhouse_log_volume_id}
  secrets:
    clickhouse_backup_sa: ${clickhouse_backup_sa}
    azblob_account_key: ${clickhouse_azblob_account_key}

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
    loadBalancerIps:
%{ for ip in load_balancer_ips ~}
      - ${ip}
%{ endfor ~}

secrets:
  postgres:
    database: ${postgres_database}
    password: ${postgres_password}
    port: ${postgres_port}
    user: ${postgres_user}

dfshell:
  serviceAccount:
    name: ${dfshell_service_account_name}
    roleArn: ${dfshell_role_arn}

worker-portal:
  serviceAccount:
    name: ${worker_portal_service_account_name}
    roleArn: ${worker_portal_role_arn}

operator:
  serviceAccount:
    name: ${operator_service_account_name}
    roleArn: ${operator_role_arn}

server:
  serviceAccount:
    name: ${server_service_account_name}
    roleArn: ${server_role_arn}

scheduler:
  serviceAccount:
    name: ${scheduler_service_account_name}
    roleArn: ${scheduler_role_arn}

worker:
  serviceAccount:
    name: ${worker_service_account_name}
    roleArn: ${worker_role_arn}

worker2:
  serviceAccount:
    name: ${worker_service_account_name}
    roleArn: ${worker_role_arn}

worker3:
  serviceAccount:
    name: ${worker_service_account_name}
    roleArn: ${worker_role_arn}

worker-catalog:
  serviceAccount:
    name: ${worker_catalog_service_account_name}
    roleArn: ${worker_catalog_role_arn}

worker-interactive:
  serviceAccount:
    name: ${worker_interactive_service_account_name}
    roleArn: ${worker_interactive_role_arn}

worker-singletons:
  serviceAccount:
    name: ${worker_singletons_service_account_name}
    roleArn: ${worker_singletons_role_arn}

worker-lineage:
  serviceAccount:
    name: ${worker_lineage_service_account_name}
    roleArn: ${worker_lineage_role_arn}

worker-monitor:
  serviceAccount:
    name: ${worker_monitor_service_account_name}
    roleArn: ${worker_monitor_role_arn}

storage-worker:
  serviceAccount:
    name: ${storage_worker_service_account_name}
    roleArn: ${storage_worker_role_arn}
