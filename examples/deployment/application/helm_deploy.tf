locals {
  versionfile    = "version.txt"
  config_yaml    = yamldecode(file("${path.module}/config.yaml"))
  releasechannel = data.sops_file.secrets.data["global.operator.releaseChannel"]
  namespace      = local.deployment_name
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
    command = "curl --insecure 'http://releases.datafold.com/${local.releasechannel}/releases.json' | jq -r '.[0].version' > ${path.module}/${local.versionfile}"
  }

  depends_on = [
    data.sops_file.secrets
  ]
}

data "local_file" "current_version" {
  filename   = "${path.module}/${local.versionfile}"
  depends_on = [resource.null_resource.get_current_release]
}
