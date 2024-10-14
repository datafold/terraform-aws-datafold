output "target_group_arn" {
  value = module.alb_app.target_group_arns[0]
}

output "load_balancer_ips" {
  value = local.lb_ips
}

output "load_balancer_dns" {
  value = module.alb_app.lb_dns_name
}

output "domain_name" {
  value = var.alb_certificate_domain
}
