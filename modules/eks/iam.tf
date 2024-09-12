resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.deployment_name}_eks_cluster_role"
  assume_role_policy = file("${path.module}/policies/cluster-trust-policy.json")
}

resource "aws_iam_policy" "node_autoscaling" {
  name        = "${var.deployment_name}-autoscaling"
  description = "${var.deployment_name} autoscaling policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_autoscaling" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.node_autoscaling.arn
  role       = each.value.iam_role_name
}

resource "aws_iam_policy" "bedrock_access_policy" {
  count              = var.k8s_access_bedrock ? 1 : 0

  name        = "${var.deployment_name}-bedrock"
  description = "${var.deployment_name} bedrock access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "bedrock:InvokeModel",
        ]
        Effect   = "Allow"
        Resource = var.bedrock_model_arn
      },
    ]
  })

  tags = var.tags
}

