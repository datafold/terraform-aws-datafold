resource "aws_security_group" "lambda_sg" {
  name        = "${var.deployment_name}-lambda-security-group"
  description = "Allow Lambda to access private systems"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}