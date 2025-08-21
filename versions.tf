terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.9.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.2.1"
    }
  }
}
