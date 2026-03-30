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
  description = "Certificate name as stored on the load balancer."
  type        = string
}

variable "certificate_organization" {
  description = "Organization value embedded in the temporary self-signed certificate subject."
  type        = string
  default     = "web-infra"
}

variable "certificate_validity_period_hours" {
  description = "Validity period for the temporary self-signed certificate."
  type        = number
  default     = 8760
}

variable "primary_hostname" {
  description = "Primary hostname served on HTTPS."
  type        = string
}

variable "alternate_hostname" {
  description = "Alternate hostname served on HTTPS."
  type        = string
}

variable "primary_hostname_name" {
  description = "Internal OCI hostname resource name for the primary hostname."
  type        = string
}

variable "alternate_hostname_name" {
  description = "Internal OCI hostname resource name for the alternate hostname."
  type        = string
}

variable "http_redirect_rule_set_name" {
  description = "Name of the HTTP-to-HTTPS redirect rule set."
  type        = string
}

variable "primary_backend_set_name" {
  description = "Name of the primary backend set."
  type        = string
}

variable "alternate_backend_set_name" {
  description = "Name of the alternate backend set."
  type        = string
}

variable "backend_policy" {
  description = "Load balancer policy used for backend sets."
  type        = string
  default     = "ROUND_ROBIN"
}

variable "backend_ip_address" {
  description = "Backend private IP address."
  type        = string
}

variable "primary_backend_port" {
  description = "Backend port for the primary hostname."
  type        = number
}

variable "alternate_backend_port" {
  description = "Backend port for the alternate hostname."
  type        = number
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
