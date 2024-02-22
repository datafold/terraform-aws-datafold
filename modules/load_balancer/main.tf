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

  name = "${var.deployment_name}-app"

  load_balancer_type = "application"
  internal           = var.lb_internal

  vpc_id          = var.vpc_id
  subnets         = var.vpc_public_subnets
  security_groups = [var.security_group_id]

  idle_timeout = var.lb_idle_timeout

  # See:
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-tls-listener.html
  listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

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
