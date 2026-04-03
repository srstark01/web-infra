// Inputs accepted by the reusable OCI Autonomous Database module.
variable "compartment_id" {
  description = "OCID of the compartment where the Autonomous Database will be created."
  type        = string
}

variable "display_name" {
  description = "Display name for the Autonomous Database."
  type        = string
}

variable "db_name" {
  description = "Database name for the Autonomous Database."
  type        = string
}

variable "admin_password_secret_id" {
  description = "Vault secret OCID containing the admin password for Autonomous Database creation."
  type        = string
}

variable "admin_password_secret_version_number" {
  description = "Optional secret version number for the admin password Vault secret."
  type        = number
  default     = null
}

variable "db_workload" {
  description = "Workload type for the Autonomous Database."
  type        = string
}

variable "db_version" {
  description = "Database version for the Autonomous Database."
  type        = string
}

variable "is_free_tier" {
  description = "Whether to create the Autonomous Database as an Always Free instance."
  type        = bool
}

variable "license_model" {
  description = "License model for the Autonomous Database."
  type        = string
}

variable "whitelisted_ips" {
  description = "Optional public IPs or CIDRs allowed to reach the Autonomous Database."
  type        = list(string)
  default     = []
}
