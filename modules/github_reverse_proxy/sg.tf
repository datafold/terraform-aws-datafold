resource "aws_security_group" "lambda_sg" {
  name        = "${var.deployment_name}-lambda-security-group"
  description = "Allow Lambda to access private systems"
  vpc_id      = var.vpc_id

  dynamic "egress" {
    for_each = var.use_private_egress ? [1] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  dynamic "egress" {
    for_each = var.use_private_egress ? [] : [1]
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}