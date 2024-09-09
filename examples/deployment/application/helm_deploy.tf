locals {
  versionfile    = "version.txt"
  config_yaml    = yamldecode(file("${path.module}/config.yaml"))
  releasechannel = local.config_yaml["global"]["operator"]["releaseChannel"]
  namespace      = local.deployment_name
  portal_url     = data.sops_file.secrets.data["secrets.operator.portalUrl"]
  portal_api_key = data.sops_file.secrets.data["secrets.operator.apiKey"]

  dockerconfigjson = {
    "auths" : {
      "https://us-docker.pkg.dev" = {
        email    = "support@datafold.com"
        username = "_json_key"
        password = trimspace(base64decode(data.sops_file.secrets.data["google-sa"]))
        auth = base64encode(join(":", [
          "_json_key",
        trimspace(base64decode(data.sops_file.secrets.data["google-sa"]))]))
      }
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"
  input_type  = "yaml"
}

data "sops_file" "infra" {
  source_file = "infra.yaml"
  input_type  = "yaml"
}

resource "kubernetes_namespace" "datafold" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_secret" "gcr-imagepullsecret" {
  metadata {
    name      = "datafold-docker-secret"
    namespace = local.namespace
  }
  data = {
    ".dockerconfigjson" = jsonencode(local.dockerconfigjson)
  }
  type = "kubernetes.io/dockerconfigjson"

  depends_on = [
    resource.kubernetes_namespace.datafold
  ]
}

resource "null_resource" "get_current_release" {
  triggers = { always_run = "${timestamp()}" }
  provisioner "local-exec" {
    command = <<-EOT
curl -L ${local.portal_url}/operator/v1/config \
     --header "Content: application/json" \
     --header "Authorization: Bearer ${local.portal_api_key}" \
     | jq -r '.version' > ${path.module}/${local.versionfile}
EOT
  }

  depends_on = [
    data.sops_file.secrets
  ]
}

data "local_file" "current_version" {
  filename   = "${path.module}/${local.versionfile}"
  depends_on = [resource.null_resource.get_current_release]
}
