locals {
  environment     = "prod"
  provider_region = "us-east-1"
  aws_profile     = "target_account_profile"
  kms_profile     = "target_account_profile"
  # Create this symmetric encryption key in advance (manually)
  # It is used for encrypting / decrypting the secrets files.
  kms_key         = "arn:aws:kms:us-west-2:1234567890:alias/acme-datafold"
  deployment_name = "acme-datafold"
  # Common tags to be assigned to all resources
  common_tags = {
    Terraform   = true
    Environment = local.environment
  }
}
