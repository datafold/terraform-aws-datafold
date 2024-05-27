locals {
  nlb_port = "443"
}

resource "aws_acm_certificate" "alb" {
  count = var.create_ssl_cert ? 1 : 0

  domain_name       = var.alb_certificate_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_acm_certificate" "alb" {
  count = var.alb_certificate_domain != "" ? 1 : 0

  domain      = var.alb_certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true

  depends_on = [
    aws_acm_certificate.alb
  ]
}

# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest
module "alb_app" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.2.0"

  name = var.lb_name_override == "" ? "${var.deployment_name}-app" : var.lb_name_override

  load_balancer_type = "application"
  internal           = var.lb_internal

  vpc_id          = var.vpc_id
  subnets         = var.vpc_public_subnets
  security_groups = [var.security_group_id]

  idle_timeout = var.lb_idle_timeout

  # See:
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-tls-listener.html
  listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  enable_cross_zone_load_balancing = true
  enable_deletion_protection = var.lb_deletion_protection

  target_groups = [
    {
      name                 = "${var.deployment_name}-app-tf"
      backend_protocol     = "HTTP"
      backend_port         = var.backend_app_port
      deregistration_delay = 30
      target_type          = "instance"
      health_check = {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 10
        port                = var.backend_app_port
        path                = "/nginx-health"
        interval            = 30
      }
    }
  ]

  https_listeners = [
    for alb_certificate_domain in [true] :
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = one(data.aws_acm_certificate.alb[*].arn)
      target_group_index = 0
    }
    if var.alb_certificate_domain != ""
  ]

  http_tcp_listeners = concat(
    [
      for i in [true] :
      {
        port        = 80
        protocol    = "HTTP"
        action_type = "forward"
      }
      if var.alb_certificate_domain == ""
    ],
    [
      for i in [true] :
      {
        port        = 80
        protocol    = "HTTP"
        action_type = "redirect"
        redirect = {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        }
      }
      if var.alb_certificate_domain != ""
    ]
  )

  access_logs = var.lb_access_logs
}

locals {
  vpc_public_subnets_joined = join(",", var.vpc_public_subnets)
}

data "aws_network_interface" "lb_app" {
  count = length(var.vpc_public_subnets)

  filter {
    name   = "description"
    values = ["ELB ${module.alb_app.lb_arn_suffix}"]
  }

  filter {
    name   = "subnet-id"
    values = [split(",", local.vpc_public_subnets_joined)[count.index]]
  }
}

locals {
  lb_ips = var.lb_internal ? jsonencode([for eni in data.aws_network_interface.lb_app : format("%s", eni.private_ip)]) : jsonencode([for eni in data.aws_network_interface.lb_app : format("%s", eni.association[0].public_ip)])
}

resource "aws_lb_target_group" "nlb_alb_target" {
  count = var.lb_deploy_nlb ? 1 : 0

  name        = "${var.deployment_name}-nlb-to-alb"
  target_type = "alb"
  port        = local.nlb_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
}

resource "aws_lb" "vpces_nlb" {
  count = var.lb_deploy_nlb ? 1 : 0

  name               = "${var.deployment_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.vpc_public_subnets
  security_groups    = [var.vpces_security_group_id]

  enable_cross_zone_load_balancing = true
  enable_deletion_protection = true

  enforce_security_group_inbound_rules_on_private_link_traffic = "on"
}

resource "aws_lb_listener" "nlb_front_end" {
  count = var.lb_deploy_nlb ? 1 : 0

  load_balancer_arn = aws_lb.vpces_nlb[0].arn
  port              = local.nlb_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = resource.aws_lb_target_group.nlb_alb_target[0].arn
  }
}

resource "aws_lb_target_group_attachment" "attachment-alb-nlb-tg" {
  count = var.lb_deploy_nlb ? 1 : 0

  target_group_arn = aws_lb_target_group.nlb_alb_target[0].arn
  target_id        = module.alb_app.lb_arn
  port             = local.nlb_port
}

#  ┏━┓┏━╸┏━╸╻ ╻┏━┓╻╺┳╸╻ ╻
#  ┗━┓┣╸ ┃  ┃ ┃┣┳┛┃ ┃ ┗┳┛
#  ┗━┛┗━╸┗━╸┗━┛╹┗╸╹ ╹  ╹

resource "aws_security_group_rule" "nlb_ingress" {
  count = var.lb_deploy_nlb ? 1 : 0

  type                     = "ingress"
  from_port                = local.nlb_port
  to_port                  = local.nlb_port
  protocol                 = "tcp"
  security_group_id        = var.vpces_security_group_id
  cidr_blocks              = [var.vpc_cidr]
  description              = "Allows traffic from VPCES to ALB"

  depends_on = [
    resource.aws_lb.vpces_nlb[0]
  ]
}

resource "aws_security_group_rule" "nlb_egress" {
  count = var.lb_deploy_nlb ? 1 : 0

  type                     = "egress"
  from_port                = local.nlb_port
  to_port                  = local.nlb_port
  protocol                 = "tcp"
  security_group_id        = var.vpces_security_group_id
  cidr_blocks              = [var.vpc_cidr]
  description              = "Allows traffic from NLB to ALB"

  depends_on = [
    resource.aws_lb.vpces_nlb[0]
  ]
}

# ╻ ╻┏━┓┏━╸┏━╸┏━┓
# ┃┏┛┣━┛┃  ┣╸ ┗━┓
# ┗┛ ╹  ┗━╸┗━╸┗━┛

resource "aws_vpc_endpoint_service" "vpces" {
  count = var.lb_deploy_nlb ? 1 : 0

  acceptance_required        = true
  network_load_balancer_arns = [resource.aws_lb.vpces_nlb[0].arn]
  allowed_principals         = var.lb_vpces_details.allowed_principals
  private_dns_name           = var.lb_vpces_details.private_dns_name
  supported_ip_address_types = var.lb_vpces_details.supported_ip_address_types
}
