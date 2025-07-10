resource "kubernetes_service_account_v1" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name" : "aws-load-balancer-controller"
      "app.kubernetes.io/component" : "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" : data.sops_file.infra.data["global.loadBalancerControllerArn"],
      "eks.amazonaws.com/sts-regional-endpoints" : "true"
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  wait       = false

  set {
    name  = "clusterName"
    value = data.sops_file.infra.data["global.clusterName"]
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.35.0"

  create_namespace = false

  set {
    name  = "awsRegion"
    value = local.provider_region
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-auto-scaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.sops_file.infra.data["global.clusterScalerRoleArn"]
    type  = "string"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = data.sops_file.infra.data["global.clusterName"]
  }
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
}

resource "helm_release" "datafold_crds" {
  name       = "datafold-crds"
  namespace  = local.namespace
  repository = "https://charts.datafold.com"
  chart      = "datafold-crds"
  version    = local.crd_version
}

