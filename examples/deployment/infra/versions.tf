terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
