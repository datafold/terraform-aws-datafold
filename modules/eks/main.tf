data "aws_caller_identity" "current" {}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.deployment_name}-ebs-csi-controller"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "k8s_load_balancer_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${var.deployment_name}-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

module "cluster_autoscaler_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                        = "${var.deployment_name}-cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-auto-scaler"]
    }
  }
}

module "eks" {
  # https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/docs

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21.0"
  # version = var.eks_module_version

  cluster_name    = var.deployment_name
  cluster_version = var.k8s_cluster_version

  cluster_endpoint_public_access = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    },
    kube-proxy = {
      most_recent = true
    },
    vpc-cni = {
      most_recent = true
    },
    aws-ebs-csi-driver = {
      service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.deployment_name}-ebs-csi-controller"
      most_recent              = true
      configuration_values     = jsonencode({
        "sidecars": {
          "snapshotter": {
            "forceEnable": false
          }
        }
      })
    }
  }

  vpc_id                   = var.k8s_vpc
  subnet_ids               = var.k8s_subnets
  control_plane_subnet_ids = var.k8s_control_subnets

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = var.self_managed_node_grp_default

  self_managed_node_groups = var.self_managed_node_grp

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = var.managed_node_grp_default
  }

  eks_managed_node_groups = var.managed_node_grp

  # aws-auth configmap
  create_aws_auth_configmap = var.create_aws_auth_configmap
  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_cluster_role.arn
      username = "eks_cluster_role"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users    = var.aws_auth_users
  aws_auth_accounts = var.aws_auth_accounts

  tags = var.tags
}

resource "aws_security_group_rule" "lb_ingress" {
  type                     = "ingress"
  from_port                = var.backend_app_port
  to_port                  = var.backend_app_port
  protocol                 = "tcp"
  source_security_group_id = var.lb_security_group_id
  security_group_id        = module.eks.node_security_group_id
  description              = "Allows traffic from LB to cluster nodes"

  depends_on = [
    module.eks
  ]
}

resource "aws_security_group_rule" "db_ingress" {
  type                     = "ingress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = var.db_security_group_id
  description              = "Allows traffic from cluster nodes to database"

  depends_on = [
    module.eks
  ]
}

resource "aws_security_group_rule" "node_db_egress" {
  type                     = "egress"
  from_port                = var.rds_port
  to_port                  = var.rds_port
  protocol                 = "tcp"
  source_security_group_id = var.db_security_group_id
  security_group_id        = module.eks.node_security_group_id
  description              = "Allows egress traffic to database"

  depends_on = [
    module.eks
  ]
}

locals {
  eks_asg_tag_list_nodegroup = {
    "k8s.io/cluster-autoscaler/enabled" : true
    "k8s.io/cluster-autoscaler/${var.deployment_name}" : "owned"
    "k8s.io/cluster-autoscaler/node-template/label/role" : var.deployment_name
  }
}

resource "aws_autoscaling_group_tag" "managed_node_grp" {
  for_each               = local.eks_asg_tag_list_nodegroup
  autoscaling_group_name = element(module.eks.eks_managed_node_groups_autoscaling_group_names, 0)

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }

  depends_on = [
    module.eks
  ]
}
