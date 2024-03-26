provider "aws" {
  region  = local.provider_region
  profile = local.aws_profile
  default_tags {
    tags = local.common_tags
  }
}

# Retrieve EKS cluster configuration
data "aws_eks_cluster" "cluster" {
  name = data.sops_file.infra.data["global.clusterName"]
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.sops_file.infra.data["global.clusterName"]
}
