terraform {
  backend "s3" {
    key = "acme-datafold/application/terraform.tfstate"
  }
}
