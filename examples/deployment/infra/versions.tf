terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}
