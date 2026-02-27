output "cluster_name" {
  value = module.eks.cluster_name
}

output "k8s_load_balancer_controller_role_arn" {
  value = module.k8s_load_balancer_controller_role.arn
}

output "cluster_scaler_role_arn" {
  value = module.cluster_autoscaler_role.arn
}

output "control_plane_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# dfshell
output "dfshell_role_arn" {
  value       = module.dfshell_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "dfshell_service_account_name" {
  value       = local.dfshell_service_account_name
  description = "The name of the service account for dfshell"
}

# worker_portal
output "worker_portal_role_arn" {
  value       = module.worker_portal_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_portal_service_account_name" {
  value       = local.worker_portal_service_account_name
  description = "The name of the service account for worker_portal"
}

# operator
output "operator_role_arn" {
  value       = module.operator_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "operator_service_account_name" {
  value       = local.operator_service_account_name
  description = "The name of the service account for operator"
}

# server
output "server_role_arn" {
  value       = module.server_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "server_service_account_name" {
  value       = local.server_service_account_name
  description = "The name of the service account for server"
}

# scheduler
output "scheduler_role_arn" {
  value       = module.scheduler_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "scheduler_service_account_name" {
  value       = local.scheduler_service_account_name
  description = "The name of the service account for scheduler"
}

# worker, worker1, worker2 etc.
output "worker_role_arn" {
  value       = module.worker_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_service_account_name" {
  value       = local.worker_service_account_name
  description = "The name of the service account for worker"
}

# worker_catalog
output "worker_catalog_role_arn" {
  value       = module.worker_catalog_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_catalog_service_account_name" {
  value       = local.worker_catalog_service_account_name
  description = "The name of the service account for worker_catalog"
}

# worker_interactive
output "worker_interactive_role_arn" {
  value       = module.worker_interactive_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_interactive_service_account_name" {
  value       = local.worker_interactive_service_account_name
  description = "The name of the service account for worker_interactive"
}

# worker_singletons
output "worker_singletons_role_arn" {
  value       = module.worker_singletons_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_singletons_service_account_name" {
  value       = local.worker_singletons_service_account_name
  description = "The name of the service account for worker_singletons"
}

# worker_lineage
output "worker_lineage_role_arn" {
  value       = module.worker_lineage_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_lineage_service_account_name" {
  value       = local.worker_lineage_service_account_name
  description = "The name of the service account for worker_lineage"
}

# worker_monitor
output "worker_monitor_role_arn" {
  value       = module.worker_monitor_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_monitor_service_account_name" {
  value       = local.worker_monitor_service_account_name
  description = "The name of the service account for worker_monitor"
}

# storage_worker
output "storage_worker_role_arn" {
  value       = module.storage_worker_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "storage_worker_service_account_name" {
  value       = local.storage_worker_service_account_name
  description = "The name of the service account for storage_worker"
}

# dma
output "dma_role_arn" {
  value       = module.dma_role[0].arn
  description = "The ARN of the AWS Bedrock role"
}
output "dma_service_account_name" {
  value       = local.dma_service_account_name
  description = "The name of the service account for dma"
}

# Clickhouse backup
output "clickhouse_backup_role_name" {
  value       = module.clickhouse_backup_role.arn
  description = "The name of the role for clickhouse backups"
}

# temporal
output "temporal_backup_role_arn" {
  value       = try(module.temporal_backup_role[0].arn, "")
  description = "The ARN of the IAM role for Temporal PostgreSQL backups (postgres-pod service account)"
}
