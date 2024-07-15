# Make a security group specific to NLB
resource "aws_security_group" "nlb_ingress" {
  name_prefix = "${var.deployment_name}-sg-nlb-control-plane"
  description = "Tagging security group to also allow access to CP through SG ID"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    protocol  = "tcp"
    to_port   = 443
    cidr_blocks = [var.vpn_cidr]
  }

  egress {
    from_port = 443
    protocol  = "tcp"
    to_port   = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group_rule" "nlb_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.control_plane_sg_id
  source_security_group_id = aws_security_group.nlb_ingress.id
  description              = "Allows traffic from NLB to CP"
}

# This internal NLB connects to the control plane
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.7.0"

  name               = "${var.deployment_name}-private-access"
  vpc_id             = var.vpc_id
  subnets            = var.vpc_private_subnets
  internal           = true
  load_balancer_type = "network"

  security_groups = [var.control_plane_sg_id, aws_security_group.nlb_ingress.id]

  target_groups = [{
    name             = var.deployment_name
    backend_protocol = "TCP"
    backend_port     = 443
    target_type      = "ip"
    health_check = {
      enabled  = true
      path     = "/readyz"
      protocol = "HTTPS"
      matcher  = "200"
    }
  }]

  http_tcp_listeners = [{
    port               = 443
    protocol           = "TCP"
    target_group_index = 0
  }]

  tags = var.tags
}

#data "dns_a_record_set" "nlb" {
#  host = module.nlb.lb_dns_name
#}

resource "aws_vpc_endpoint_service" "pl_control_plane" {
  acceptance_required        = true
  network_load_balancer_arns = [module.nlb.lb_arn]
  allowed_principals         = var.allowed_principals

  tags = merge(var.tags,
    { Name = "${var.deployment_name}-private-access" },
  )
}


################################################################################
# Lambda - Create ENI IPs to NLB Target Group
################################################################################

module "create_eni_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  function_name = "${var.deployment_name}-add-eni-ips"
  description   = "Add ENI IPs to NLB target group when EKS API endpoint is created"
  handler       = "create_eni.handler"
  runtime       = "python3.10"
  publish       = true
  source_path   = "${path.module}/lambdas"

  attach_policy_json = true
  policy_json        = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "elasticloadbalancing:RegisterTargets"
          ],
          "Resource": ["${module.nlb.target_group_arns[0]}"]
        }
      ]
    }
  EOT

  environment_variables = {
    TARGET_GROUP_ARN = module.nlb.target_group_arns[0]
  }

  allowed_triggers = {
    eventbridge = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["eks-api-endpoint-create"]
    }
  }

  tags = var.tags
}

################################################################################
# Lambda - Delete ENI IPs from NLB Target Group
################################################################################

module "delete_eni_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  function_name = "${var.deployment_name}-delete-eni-ips"
  description   = "Deletes ENI IPs from NLB target group when EKS API endpoint is deleted"
  handler       = "delete_eni.handler"
  runtime       = "python3.10"
  publish       = true
  source_path   = "${path.module}/lambdas"

  attach_policy_json = true
  policy_json        = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeNetworkInterfaces",
            "elasticloadbalancing:Describe*"
          ],
          "Resource": ["*"]
        },
        {
          "Effect": "Allow",
          "Action": [
            "elasticloadbalancing:DeregisterTargets"
          ],
          "Resource": ["${module.nlb.target_group_arns[0]}"]
        }
      ]
    }
  EOT

  environment_variables = {
    TARGET_GROUP_ARN = module.nlb.target_group_arns[0]

    # Passing local.name in lieu of module.eks.cluster_name to avoid dependency
    EKS_CLUSTER_NAME = var.eks_cluster_name
  }

  allowed_triggers = {
    eventbridge = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["eks-api-endpoint-delete"]
    }
  }

  tags = var.tags
}

################################################################################
# EventBridge Rules
################################################################################

module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 2.0"

  # Use the existing default event bus
  create_bus = false

  role_name = "${var.deployment_name}-evb-privaxs-role"

  rules = {
    eks-api-endpoint-create = {
      event_pattern = jsonencode({
        "source" : ["aws.ec2"],
        "detail-type" : ["AWS API Call via CloudTrail"],
        "detail" : {
          "eventSource" : ["ec2.amazonaws.com"],
          "eventName" : ["CreateNetworkInterface"],
          "sourceIPAddress" : ["eks.amazonaws.com"],
          "responseElements" : {
            "networkInterface" : {
              "description" : ["Amazon EKS ${var.deployment_name}"]
            }
          }
        }
      })
      enabled = true
    }

    eks-api-endpoint-delete = {
      description         = "Trigger for a Lambda"
      schedule_expression = "rate(15 minutes)"
    }
  }

  targets = {
    eks-api-endpoint-create = [
      {
        name = module.create_eni_lambda.lambda_function_name
        arn  = module.create_eni_lambda.lambda_function_arn
      }
    ]
    eks-api-endpoint-delete = [
      {
        name = module.delete_eni_lambda.lambda_function_name
        arn  = module.delete_eni_lambda.lambda_function_arn
      }
    ]
  }

  tags = var.tags
}