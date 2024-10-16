module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.3.0"

  name   = "${var.deployment_name}-db"
  vpc_id = var.vpc_id

  tags = var.sg_tags
}

resource "aws_security_group" "load_balancer_sg" {
  name   = "${var.deployment_name}-lb"
  vpc_id = var.vpc_id

  tags = merge(
    var.sg_tags,
    {
      Name = "${var.deployment_name}-lb"
    }
  )
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.whitelisted_ingress_cidrs
  security_group_id = aws_security_group.load_balancer_sg.id
  description       = "Allow HTTPS from whitelisted CIDRs"
}

resource "aws_security_group_rule" "ingress_http" {
  count = var.ingress_enable_http_sg ? 1 : 0

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.whitelisted_ingress_cidrs
  security_group_id = aws_security_group.load_balancer_sg.id
  description       = "Allow HTTP from whitelisted CIDRs"
}

# Egress rule for the backend app port
resource "aws_security_group_rule" "egress_backend" {
  type              = "egress"
  from_port         = var.backend_app_port
  to_port           = var.backend_app_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.load_balancer_sg.id
  description       = "Egress for all traffic to the backend app"
}

module "vpces_sg" {
  count = var.lb_deploy_nlb ? 1 : 0

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.3.0"

  name   = "${var.deployment_name}-nlb-sg"
  vpc_id = var.vpc_id

  tags = var.sg_tags
}

locals {
  vpce_security_group_id = (
    try(
      module.vpces_sg[0].security_group_id,
      ""
    )
  )
}