output "target_group_arn" {
  value = module.alb_app.target_group_arns[0]
}

output "load_balancer_ips" {
  value = "{${join(",", [for eni in data.aws_network_interface.lb_app : format("%s", eni.association[0].public_ip)])}}"
  # value = [for eni in data.aws_network_interface.lb_app : format("\"%s\"", eni.association[0].public_ip)]
}

output "domain_name" {
  value = var.alb_certificate_domain
}
