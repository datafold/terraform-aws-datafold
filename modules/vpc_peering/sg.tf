resource "aws_security_group_rule" "peer_ingress_https" {
  for_each = var.peer_vpc_additional_whitelisted_ingress_cidrs

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.peer_vpc_cidr_block]
  security_group_id = var.lb_security_group_id
  description       = "Allow HTTPS from whitelisted CIDRs (peer)"
}

resource "aws_security_group_rule" "peer_ingress_http" {
  for_each = var.ingress_enable_http_sg ? var.peer_vpc_additional_whitelisted_ingress_cidrs : []

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.peer_vpc_cidr_block]
  security_group_id = var.lb_security_group_id
  description       = "Allow HTTP from whitelisted CIDRs (peer)"
}
