# Container logs to CloudWatch Logs through the Amazon CloudWatch Observability
# add-on: a Fluent Bit DaemonSet tails every container's stdout on the node and
# ships it to /aws/containerinsights/<cluster>/application, so applications log to
# stdout and need no collector or hostPath of their own.
#
# The add-on's defaults are not what we want, so its configuration sets:
# - Application Signals off. Its auto-monitor otherwise injects the ADOT
#   auto-instrumentation into every Python/Java/.NET/Node workload in regions
#   that support it, on top of the OpenTelemetry the apps already run.
# - Container Insights at the standard tier, not "enhanced" (billed per
#   observation). The CloudWatch agent DaemonSet runs whatever is configured,
#   and with no feature at all its config is empty and it exits on start, so
#   it keeps the standard node/pod metrics.
#
# Fluent Bit creates its log groups with no retention (never expire), so they
# are created here first, with one.

locals {
  cloudwatch_observability_log_groups = toset(["application", "dataplane", "host", "performance"])

  cloudwatch_observability_configuration = jsonencode({
    containerLogs      = { enabled = true }
    applicationSignals = { enabled = false }
    manager = {
      applicationSignals = { autoMonitor = { monitorAllServices = false } }
    }
    agent = {
      config = {
        logs = {
          metrics_collected = {
            kubernetes = { enhanced_container_insights = false }
          }
        }
      }
    }
  })
}

resource "aws_cloudwatch_log_group" "container_insights" {
  for_each = var.cloudwatch_observability.enabled ? local.cloudwatch_observability_log_groups : toset([])

  name              = "/aws/containerinsights/${module.eks.cluster_name}/${each.key}"
  retention_in_days = var.cloudwatch_observability.log_retention_days

  tags = var.tags
}

module "cloudwatch_observability_role" {
  count   = var.cloudwatch_observability.enabled ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.2.1"

  name                                   = "${var.deployment_name}-cloudwatch-observability"
  attach_cloudwatch_observability_policy = true
  use_name_prefix                        = false

  oidc_providers = {
    ex = {
      provider_arn = module.eks.oidc_provider_arn
      # Both the CloudWatch agent and Fluent Bit run as this service account.
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }
}

data "aws_eks_addon_version" "cloudwatch_observability" {
  count = var.cloudwatch_observability.enabled ? 1 : 0

  addon_name         = "amazon-cloudwatch-observability"
  kubernetes_version = module.eks.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "cloudwatch_observability" {
  count = var.cloudwatch_observability.enabled ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = data.aws_eks_addon_version.cloudwatch_observability[0].version
  service_account_role_arn    = module.cloudwatch_observability_role[0].arn
  configuration_values        = coalesce(var.cloudwatch_observability.configuration_values, local.cloudwatch_observability_configuration)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  # The log groups must exist before Fluent Bit starts, or it creates them
  # without retention and creating them here fails.
  depends_on = [aws_cloudwatch_log_group.container_insights]
}
