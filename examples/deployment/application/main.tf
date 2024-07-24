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
    "${data.sops_file.infra.raw}",
    "${file("config.yaml")}",
    "${data.sops_file.secrets.raw}"
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
    name  = "global.datadog.install"
    value = false
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
    name  = "secrets.clickhouse.password"
    value = random_password.clickhouse_password.result
  }
  set {
    name  = "secrets.redis.password"
    value = random_password.redis_password.result
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

resource "random_password" "clickhouse_password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  special          = false
}

resource "random_password" "redis_password" {
  length           = 12
  special          = false
}
