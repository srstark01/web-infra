// Inputs accepted by the reusable OCI load balancer module.
variable "compartment_id" {
  description = "OCID of the compartment where the load balancer will be created."
  type        = string
}

variable "display_name" {
  description = "Display name for the load balancer."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet OCIDs where the load balancer will be attached."
  type        = list(string)
}

variable "network_security_group_ids" {
  description = "NSG OCIDs to attach to the load balancer."
  type        = list(string)
  default     = []
}

variable "shape" {
  description = "OCI load balancer shape."
  type        = string
  default     = "flexible"
}

variable "minimum_bandwidth_in_mbps" {
  description = "Minimum bandwidth in Mbps for the flexible load balancer."
  type        = number
  default     = 10
}

variable "maximum_bandwidth_in_mbps" {
  description = "Maximum bandwidth in Mbps for the flexible load balancer."
  type        = number
  default     = 10
}

variable "is_private" {
  description = "Whether the load balancer should be private."
  type        = bool
  default     = false
}

variable "certificate_name" {
  description = "Existing certificate name already present on the load balancer."
  type        = string
}

variable "certificate_mode" {
  description = "Certificate source mode for HTTPS listeners: bootstrap creates a temporary self-signed cert, external expects an existing OCI LB certificate bundle, and auto prefers the external cert when present and otherwise falls back to bootstrap."
  type        = string
  default     = "auto"

  validation {
    condition     = contains(["bootstrap", "external", "auto"], var.certificate_mode)
    error_message = "certificate_mode must be one of \"bootstrap\", \"external\", or \"auto\"."
  }
}

variable "bootstrap_certificate_name" {
  description = "Certificate name to use for the temporary bootstrap self-signed certificate."
  type        = string
  default     = "staging-self-signed"
}

variable "bootstrap_certificate_organization" {
  description = "Organization value embedded in the temporary bootstrap self-signed certificate subject."
  type        = string
  default     = "web-infra"
}

variable "bootstrap_certificate_validity_period_hours" {
  description = "Validity period for the temporary bootstrap self-signed certificate."
  type        = number
  default     = 8760
}

variable "http_redirect_rule_set_name" {
  description = "Name of the HTTP-to-HTTPS redirect rule set."
  type        = string
}

variable "backend_policy" {
  description = "Load balancer policy used for backend sets."
  type        = string
  default     = "ROUND_ROBIN"
}

variable "backend_sets" {
  description = "Backend sets to create, including their listener port and backend IP addresses."
  type = list(object({
    name        = string
    port        = number
    backend_ips = list(string)
  }))
}

variable "listeners" {
  description = "Hostname-based HTTPS listeners and the backend set each should route to."
  type = list(object({
    name             = string
    hostname         = string
    backend_set_name = string
  }))
}

variable "http_default_backend_set_name" {
  description = "Backend set used as the HTTP listener default before redirect rules are applied."
  type        = string
}

variable "health_check_path" {
  description = "Path used for HTTPS health checks."
  type        = string
  default     = "/"
}

variable "health_check_force_plain_text" {
  description = "Whether HTTP health checks should skip backend TLS."
  type        = bool
  default     = true
}

variable "enable_backend_ssl" {
  description = "Whether the load balancer should use TLS when connecting to backends."
  type        = bool
  default     = false
}

variable "health_check_return_code" {
  description = "Expected status code from the backend health check."
  type        = number
  default     = 200
}

variable "health_check_retries" {
  description = "Retry count for backend health checks."
  type        = number
  default     = 3
}

variable "health_check_interval_ms" {
  description = "Health check interval in milliseconds."
  type        = number
  default     = 10000
}

variable "health_check_timeout_in_millis" {
  description = "Health check timeout in milliseconds."
  type        = number
  default     = 3000
}

variable "verify_backend_peer_certificate" {
  description = "Whether to verify the backend TLS certificate."
  type        = bool
  default     = false
}
