output "target_group_arn" {
  value = module.alb_app.target_group_arns[0]
}

output "load_balancer_ips" {
  value = local.lb_ips
}

output "domain_name" {
  value = var.alb_certificate_domain
}
