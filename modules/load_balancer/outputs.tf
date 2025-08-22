output "target_group_arn" {
  value = var.deploy_lb ? module.alb_app[0].target_group_arns[0] : "not_deployed"
}

output "load_balancer_ips" {
  value = local.lb_ips
}

output "load_balancer_dns" {
  value = var.deploy_lb ? module.alb_app[0].lb_dns_name : "not_deployed"
}

output "domain_name" {
  value = var.alb_certificate_domain
}
