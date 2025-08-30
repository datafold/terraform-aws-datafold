# Policies

resource "aws_iam_policy" "bedrock_access_policy" {
  count       = var.k8s_access_bedrock ? 1 : 0
  name        = "${var.deployment_name}-bedrock-access-policy"
  description = "Policy that allows access to AWS Bedrock services"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "bedrock:TagResource",
          "bedrock:CreateInferenceProfile",
          "bedrock:GetFoundationModel",
          "bedrock:GetInferenceProfile",
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:ListInferenceProfiles",
        ],
        Resource = "*"
      }
    ]
  })

  tags = var.sg_tags
}

resource "aws_iam_policy" "clickhouse_backup_policy" {
  name        = "${var.deployment_name}-clickhouse-backup-policy"
  description = "Policy that allows clickhouse to make backups"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
        ],
        Resource = [var.clickhouse_backup_bucket_arn]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "${var.clickhouse_backup_bucket_arn}/*"
        ]
      }
    ]
  })
}

#
# Roles
# 

# dfshell
module "dfshell_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.dfshell_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.dfshell_service_account_name}"]
    }
  }
}

# worker_portal
module "worker_portal_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.worker_portal_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.worker_portal_service_account_name}"]
    }
  }
}

# operator
module "operator_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.operator_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.operator_service_account_name}"]
    }
  }
}

# server
module "server_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.server_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.server_service_account_name}"]
    }
  }
}

# scheduler
module "scheduler_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.scheduler_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.scheduler_service_account_name}"]
    }
  }
}

# worker
module "worker_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.worker_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.worker_service_account_name}"]
    }
  }
}

# worker_catalog
module "worker_catalog_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.worker_catalog_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.worker_catalog_service_account_name}"]
    }
  }
}

# worker_interactive
module "worker_interactive_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.worker_interactive_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.worker_interactive_service_account_name}"]
    }
  }
}

# worker_singletons
module "worker_singletons_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.worker_singletons_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.worker_singletons_service_account_name}"]
    }
  }
}

# worker_lineage
module "worker_lineage_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.worker_lineage_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.worker_lineage_service_account_name}"]
    }
  }
}

# worker_monitor
module "worker_monitor_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.worker_monitor_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.worker_monitor_service_account_name}"]
    }
  }
}

# storage_worker
module "storage_worker_role" {
  count   = 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.storage_worker_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.storage_worker_service_account_name}"]
    }
  }
}

module "clickhouse_backup_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name    = "${var.deployment_name}-${var.clickhouse_backup_service_account_name}"
  version = "6.2.1"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.deployment_name}:${var.clickhouse_backup_service_account_name}"]
    }
  }
}

# Policy Attachments
resource "aws_iam_role_policy_attachment" "bedrock_dfshell_attachment" {
  count      = var.k8s_access_bedrock ? 1 : 0
  role       = module.dfshell_role[0].name
  policy_arn = aws_iam_policy.bedrock_access_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_server_attachment" {
  count      = var.k8s_access_bedrock ? 1 : 0
  role       = module.server_role[0].name
  policy_arn = aws_iam_policy.bedrock_access_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_worker_attachment" {
  count      = var.k8s_access_bedrock ? 1 : 0
  role       = module.worker_role[0].name
  policy_arn = aws_iam_policy.bedrock_access_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_worker_interactive_attachment" {
  count      = var.k8s_access_bedrock ? 1 : 0
  role       = module.worker_interactive_role[0].name
  policy_arn = aws_iam_policy.bedrock_access_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "clickhouse_backup_attachment" {
  role       = module.clickhouse_backup_role.name
  policy_arn = aws_iam_policy.clickhouse_backup_policy.arn
}

