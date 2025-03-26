output "domain_name" {
  value = coalesce(var.host_override, var.alb_certificate_domain)
  description = "The domain name to be used in DNS configuration"
}

output "db_instance_id" {
  value = module.database.db_instance_id
  description = "The ID of the RDS database instance"
}

output "deployment_name" {
  value = var.deployment_name
  description = "The name of the deployment"
}

output "lb_name" {
  value       = "${var.deployment_name}-app"
  description = "The name of the external load balancer"
}

output "target_group_arn" {
  value = module.load_balancer.target_group_arn
  description = "The ARN to the target group where the pods need to be registered as targets."
}

output "security_group_id" {
  value = module.security.lb_security_group_id
  description = "The security group ID managing ingress from the load balancer"
}

output "postgres_username" {
  value = module.database.postgres_username
  description = "The postgres username to be used by the application"
}

output "postgres_password" {
  value = module.database.postgres_password
  description = "The generated postgres password to be used by the application"
}

output "postgres_database_name" {
  value = module.database.postgres_database_name
  description = "The name of the pre-provisioned database."
}

output "postgres_host" {
  value = module.database.postgres_host
  description = "The DNS name for the postgres database"
}

output "postgres_port" {
  value = module.database.postgres_port
  description = "The port configured for the RDS database"
}

output "load_balancer_ips" {
  value = module.load_balancer.load_balancer_ips
  description = "The load balancer IP when it was provisioned."
}

output "cloud_provider" {
  value = "aws"
  description = "A string describing the type of cloud provider to be passed onto the helm charts"
}

output "cluster_name" {
  value = module.eks.cluster_name
  description = "The name of the EKS cluster"
}

output "k8s_load_balancer_controller_role_arn" {
  value = module.eks.k8s_load_balancer_controller_role_arn
  description = "The ARN of the role provisioned so the k8s cluster can edit the target group through the AWS load balancer controller."
}

output "cluster_scaler_role_arn" {
  value = module.eks.cluster_scaler_role_arn
  description = "The ARN of the role that is able to scale the EKS cluster nodes."
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "The URL to the EKS cluster endpoint"
}

output "vpc_cidr" {
  value = module.networking.vpc_cidr
  description = "The CIDR of the entire VPC"
}

output "vpc_id" {
  value = module.networking.vpc_id
  description = "The ID of the VPC"
}

output "clickhouse_password" {
  value = resource.random_password.clickhouse_password.result
  description = "The generated clickhouse password to be used in the application deployment"
}

output "redis_password" {
  value = resource.random_password.redis_password.result
  description = "The generated redis password to be used in the application deployment"
}

output "clickhouse_data_volume_id" {
  value = resource.aws_ebs_volume.clickhouse_data.id
  description = "The EBS volume ID where clickhouse data will be stored."
}

output "clickhouse_logs_volume_id" {
  value = resource.aws_ebs_volume.clickhouse_logs.id
  description = "The EBS volume ID where clickhouse logs will be stored."
}

output "clickhouse_data_size" {
  value = var.clickhouse_data_size
  description = "The size in GB of the clickhouse EBS data volume"
}

output "clickhouse_logs_size" {
  value = var.clickhouse_logs_size
  description = "The size in GB of the clickhouse EBS logs volume"
}

output "clickhouse_s3_bucket" {
  value = module.clickhouse_backup.clickhouse_s3_bucket
  description = "The location of the S3 bucket where clickhouse backups are stored"
}

output "clickhouse_s3_region" {
  value = module.clickhouse_backup.clickhouse_s3_region
  description = "The region where the S3 bucket is created"
}

output "clickhouse_access_key" {
  value = module.clickhouse_backup.clickhouse_access_key
  description = "The access key of the IAM user doing the clickhouse backups."
}

output "clickhouse_secret_key" {
  value = module.clickhouse_backup.clickhouse_secret_key
  description = "The secret key of the IAM user doing the clickhouse backups."
}

output "private_access_vpces_name" {
  value = coalesce(one(module.private_access[*].private_vpces_name), "not active")
  description = "Name of the VPCE service that allows private access to the cluster endpoint"
}

output "redis_data_size" {
  value = var.redis_data_size
  description = "The size in GB of the Redis data volume."
}

output "redis_data_volume_id" {
  value = resource.aws_ebs_volume.redis_data.id
  description = "The EBS volume ID of the Redis data volume."
}

output "vpces_azs" {
  value = coalesce(one(module.private_access[*].private_access_az), "not active")
  description = "Set of availability zones where the VPCES is available."
}

output "github_reverse_proxy_url" {
  value = coalesce(one(module.github_reverse_proxy[*].api_gateway_url), "not active")
  description = "The URL of the API Gateway that acts as a reverse proxy to the GitHub API"
}

# dfshell
output "dfshell_role_arn" {
  value = module.eks.dfshell_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "dfshell_service_account_name" {
  value = module.eks.dfshell_service_account_name
  description = "The name of the service account for dfshell"
}

# worker_portal
output "worker_portal_role_arn" {
  value = module.eks.worker_portal_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_portal_service_account_name" {
  value = module.eks.worker_portal_service_account_name
  description = "The name of the service account for worker_portal"
}

# operator
output "operator_role_arn" {
  value = module.eks.operator_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "operator_service_account_name" {
  value = module.eks.operator_service_account_name
  description = "The name of the service account for operator"
}

# server
output "server_role_arn" {
  value = module.eks.server_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "server_service_account_name" {
  value = module.eks.server_service_account_name
  description = "The name of the service account for server"
}

# scheduler
output "scheduler_role_arn" {
  value = module.eks.scheduler_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "scheduler_service_account_name" {
  value = module.eks.scheduler_service_account_name
  description = "The name of the service account for scheduler"
}

# worker, worker1, worker2 etc.
output "worker_role_arn" {
  value = module.eks.worker_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_service_account_name" {
  value = module.eks.worker_service_account_name
  description = "The name of the service account for worker"
}

# worker_catalog
output "worker_catalog_role_arn" {
  value = module.eks.worker_catalog_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_catalog_service_account_name" {
  value = module.eks.worker_catalog_service_account_name
  description = "The name of the service account for worker_catalog"
}

# worker_interactive
output "worker_interactive_role_arn" {
  value = module.eks.worker_interactive_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_interactive_service_account_name" {
  value = module.eks.worker_interactive_service_account_name
  description = "The name of the service account for worker_interactive"
}

# worker_singletons
output "worker_singletons_role_arn" {
  value = module.eks.worker_singletons_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_singletons_service_account_name" {
  value = module.eks.worker_singletons_service_account_name
  description = "The name of the service account for worker_singletons"
}

# worker_lineage
output "worker_lineage_role_arn" {
  value = module.eks.worker_lineage_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_lineage_service_account_name" {
  value = module.eks.worker_lineage_service_account_name
  description = "The name of the service account for worker_lineage"
}

# worker_monitor
output "worker_monitor_role_arn" {
  value = module.eks.worker_monitor_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "worker_monitor_service_account_name" {
  value = module.eks.worker_monitor_service_account_name
  description = "The name of the service account for worker_monitor"
}

# storage_worker
output "storage_worker_role_arn" {
  value = module.eks.storage_worker_role_arn
  description = "The ARN of the AWS Bedrock role"
}
output "storage_worker_service_account_name" {
  value = module.eks.storage_worker_service_account_name
  description = "The name of the service account for storage_worker"
}