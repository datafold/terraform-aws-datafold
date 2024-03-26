provider "aws" {
  region  = local.provider_region
  profile = local.aws_profile
  default_tags {
    tags = local.common_tags
  }
}

provider "datadog" {
  api_key = var.dd_api_key
  app_key = var.dd_app_key
  # In the EU, use https://api.datadoghq.eu/
  api_url                   = "https://api.datadoghq.com/"
  http_client_retry_enabled = true
  http_client_retry_timeout = 60
}
