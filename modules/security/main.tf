# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws
module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.3.0"

  name   = "${var.deployment_name}-app"
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
    ],
    [
      {
         description = "Ingress for all in CIDR"
         from_port   = 5432
         to_port     = 5432
         protocol    = "tcp"
         cidr_blocks = var.vpc_cidr
      }
    ]
  )

  egress_with_cidr_blocks = concat([
    {
      rule        = "all-all"
      cidr_blocks = join(",", sort(distinct(concat(var.whitelisted_egress_cidrs))))
    }
    ],
    [
      for enabled in [true] :
      {
        rule        = "dns-tcp"
        cidr_blocks = join(",", sort(var.dns_egress_cidrs))
      }
      if length(var.dns_egress_cidrs) > 0
    ],
    [
      {
         description = "Egress for all in CIDR"
         from_port   = 5432
         to_port     = 5432
         protocol    = "tcp"
         cidr_blocks = var.vpc_cidr
      }
    ]
  )

  tags = var.sg_tags
}
