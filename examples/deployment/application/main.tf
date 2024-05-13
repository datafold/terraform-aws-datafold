resource "helm_release" "datafold" {
  name       = "datafold"
  namespace  = local.namespace
  repository = "https://charts.datafold.com"
  chart      = "datafold"
  version    = local.helm_version
  wait       = false

  set {
    name  = "foo"
    value = "bar"
  }

  values = [
    "${data.sops_file.infra.raw}"
  ]

  set {
    name  = "operator.image.tag"
    value = local.operator_version
  }
  set {
    name  = "global.datadog.env"
    value = "prod"
  }
  set {
    name  = "clickhouse.movedata"
    value = "false"
  }
  set {
    name  = "global.datadog.install"
    value = true
  }
  set {
    name  = "global.deployment"
    value = local.deployment_name
  }
  set {
    name  = "global.datafoldVersion"
    value = trimspace("${data.local_file.current_version.content}")
  }
  set {
    name  = "global.operator.allowRollback"
    value = data.sops_file.secrets.data["global.operator.allowRollback"]
  }
  set {
    name  = "global.operator.releaseChannel"
    value = data.sops_file.secrets.data["global.operator.releaseChannel"]
  }
  set {
    name  = "global.operator.backupCronSchedule"
    value = data.sops_file.secrets.data["global.operator.backupCronSchedule"]
  }
  set {
    name  = "global.operator.maintenanceWindow"
    value = data.sops_file.secrets.data["global.operator.maintenanceWindow"]
  }
  set {
    name  = "postgres.install"
    value = false
  }
  set {
    name  = "secrets.clickhouse.user"
    value = "default"
  }
  set {
    name  = "secrets.freshpaint.url"
    value = "https://api.perfalytics.com/track"
  }
  set {
    name  = "secrets.installMePassword"
    value = data.sops_file.secrets.data["secrets.installMePassword"]
  }
  set {
    name  = "secrets.mail.defaultSender"
    value = data.sops_file.secrets.data["secrets.mail.defaultSender"]
  }
  set {
    name  = "secrets.mail.server"
    value = data.sops_file.secrets.data["secrets.mail.server"]
  }

  depends_on = [
    resource.kubernetes_namespace.datafold,
    resource.kubernetes_service_account_v1.aws_lb_controller,
    resource.helm_release.aws_lb_controller,
    resource.helm_release.datafold_crds,
    resource.helm_release.datadog,
    data.local_file.current_version,
  ]
}
