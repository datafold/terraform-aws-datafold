output "cluster_name" {
  value = module.eks.cluster_name
}

output "k8s_load_balancer_controller_role_arn" {
  value = module.k8s_load_balancer_controller_role.iam_role_arn
}

output "cluster_scaler_role_arn" {
  value = module.cluster_autoscaler_role.iam_role_arn
}
