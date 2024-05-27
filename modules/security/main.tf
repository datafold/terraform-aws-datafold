module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.3.0"

  name   = "${var.deployment_name}-db"
  vpc_id = var.vpc_id

  tags = var.sg_tags
}

module "load_balancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.3.0"

  name   = "${var.deployment_name}-lb"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = concat(
    [
      {
        rule        = "https-443-tcp"
        cidr_blocks = join(",", sort(var.whitelisted_ingress_cidrs))
      }
    ],
    [
      for enabled in [true] :
      {
        rule        = "http-80-tcp"
        cidr_blocks = join(",", sort(var.whitelisted_ingress_cidrs))
      }
      if var.ingress_enable_http_sg
    ]
  )

  egress_with_cidr_blocks = concat(
    [
      {
         description = "Egress for all in CIDR"
         from_port   = var.backend_app_port
         to_port     = var.backend_app_port
         protocol    = "tcp"
         cidr_blocks = var.vpc_cidr
      }
    ]
  )

  tags = var.sg_tags
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