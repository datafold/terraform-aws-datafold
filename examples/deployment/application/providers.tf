locals {
  # Socks5 proxy over SSH
  proxy_url = "socks5://localhost:1080"
  # HTTP proxy over SSH
  # proxy_url = "http://localhost:8888"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    # For use with a local proxy to a restricted public endpoint
    # proxy_url              = local.proxy_url
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "--profile", local.aws_profile, "--region", local.provider_region, "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  # For use with a local proxy to a restricted public endpoint
  # proxy_url              = local.proxy_url
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "--profile", local.aws_profile, "--region", local.provider_region, "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}
