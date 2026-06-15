variable "backend_app_port" {
  type        = number
  default     = 31337
  description = "The backend app port to target on kubernetes. Old deployments rely on default in module."
}

variable "status_check_token" {
  type        = string
  default     = null
  description = "The status check token used by the server /livez and /readyz probes. When left unset (null), a random token is generated automatically."
}
