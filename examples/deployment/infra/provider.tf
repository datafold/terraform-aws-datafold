provider "aws" {
  region  = local.provider_region
  profile = local.aws_profile
  default_tags {
    tags = local.common_tags
  }
}
