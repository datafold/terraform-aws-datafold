variable "dd_app_key" {
  type        = string
  description = "The APP key is used to call the datadog API (we use this)."
}

variable "dd_api_key" {
  type        = string
  description = "The API key is not used, but provider insists on setting it. Fine."
}

variable "backend_app_port" {
  type        = number
  default     = 31337
  description = "The backend app port to target on kubernetes. Old deployments rely on default in module."
}

variable "status_check_token" {
  type        = string
  default     = "token"
  description = "The status check token to apply"
}

