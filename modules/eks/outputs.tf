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