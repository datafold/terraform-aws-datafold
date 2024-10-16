output "lb_security_group_id" {
  value = aws_security_group.load_balancer_sg.id
}

output "db_security_group_id" {
  value = module.db_sg.security_group_id
}

output "vpces_sec_group_id" {
  value = local.vpce_security_group_id
}
