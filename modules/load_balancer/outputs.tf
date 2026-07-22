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

output "vpces_name" {
  value       = try(aws_vpc_endpoint_service.vpces[0].service_name, "not_deployed")
  description = "Service name of the VPC Endpoint Service fronting the UI, for consumer-side PrivateLink connections"
}

output "vpces_az_id" {
  value       = try(data.aws_subnet.vpces_az[0].availability_zone_id, "not_deployed")
  description = "Availability zone ID of the UI's VPCE service, for the consumer side to pick a matching subnet"
}
