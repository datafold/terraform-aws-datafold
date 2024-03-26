provider "aws" {
  region  = "us-west-2"
  profile = "target_account_profile"
}

resource "aws_s3_bucket" "state-bucket" {
  bucket = "${var.deployment_name}-terraform-state"
}

resource "aws_dynamodb_table" "dynamodb-lock-table" {
  name         = "${var.deployment_name}-lock-table"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "prod"
  }
}
