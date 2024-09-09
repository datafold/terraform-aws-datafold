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
