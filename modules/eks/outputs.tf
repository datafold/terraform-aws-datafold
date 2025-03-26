output "cluster_name" {
  value = module.eks.cluster_name
}

output "k8s_load_balancer_controller_role_arn" {
  value = module.k8s_load_balancer_controller_role.iam_role_arn
}

output "cluster_scaler_role_arn" {
  value = module.cluster_autoscaler_role.iam_role_arn
}

output "control_plane_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# dfshell
output "dfshell_role_arn" {
  value = module.dfshell_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "dfshell_service_account_name" {
  value = var.dfshell_service_account_name
  description = "The name of the service account for dfshell"
}

# worker_portal
output "worker_portal_role_arn" {
  value = module.worker_portal_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_portal_service_account_name" {
  value = var.worker_portal_service_account_name
  description = "The name of the service account for worker_portal"
}

# operator
output "operator_role_arn" {
  value = module.operator_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "operator_service_account_name" {
  value = var.operator_service_account_name
  description = "The name of the service account for operator"
}

# server
output "server_role_arn" {
  value = module.server_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "server_service_account_name" {
  value = var.server_service_account_name
  description = "The name of the service account for server"
}

# scheduler
output "scheduler_role_arn" {
  value = module.scheduler_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "scheduler_service_account_name" {
  value = var.scheduler_service_account_name
  description = "The name of the service account for scheduler"
}

# worker, worker1, worker2 etc.
output "worker_role_arn" {
  value = module.worker_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_service_account_name" {
  value = var.worker_service_account_name
  description = "The name of the service account for worker"
}

# worker_catalog
output "worker_catalog_role_arn" {
  value = module.worker_catalog_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_catalog_service_account_name" {
  value = var.worker_catalog_service_account_name
  description = "The name of the service account for worker_catalog"
}

# worker_interactive
output "worker_interactive_role_arn" {
  value = module.worker_interactive_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_interactive_service_account_name" {
  value = var.worker_interactive_service_account_name
  description = "The name of the service account for worker_interactive"
}

# worker_singletons
output "worker_singletons_role_arn" {
  value = module.worker_singletons_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_singletons_service_account_name" {
  value = var.worker_singletons_service_account_name
  description = "The name of the service account for worker_singletons"
}

# worker_lineage
output "worker_lineage_role_arn" {
  value = module.worker_lineage_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_lineage_service_account_name" {
  value = var.worker_lineage_service_account_name
  description = "The name of the service account for worker_lineage"
}

# worker_monitor
output "worker_monitor_role_arn" {
  value = module.worker_monitor_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_monitor_service_account_name" {
  value = var.worker_monitor_service_account_name
  description = "The name of the service account for worker_monitor"
}

# storage_worker
output "storage_worker_role_arn" {
  value = module.storage_worker_role[0].iam_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "storage_worker_service_account_name" {
  value = var.storage_worker_service_account_name
  description = "The name of the service account for storage_worker"
}