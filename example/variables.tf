variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type        = string
  default     = null
  description = "Client secret for service principal authentication. Only required when use_oidc is false or null."

  validation {
    condition = (
      var.use_oidc == true || var.client_secret != null
    )
    error_message = "client_secret is required when use_oidc is false or null."
  }
}

variable "use_oidc" {
  type    = bool
  default = false
}

