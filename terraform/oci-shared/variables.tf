// OCI provider authentication and targeting values for the shared stack.
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "user_ocid" {
  description = "OCI user OCID used by Terraform."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint for the OCI API key."
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key."
  type        = string
}

variable "region" {
  description = "OCI region for provider operations."
  type        = string
}

// Inputs controlling the shared parent compartment.
variable "project_name" {
  description = "Base project name used in resource naming."
  type        = string
  default     = "web-infra"
}

variable "project_compartment_description" {
  description = "Description for the parent project compartment."
  type        = string
  default     = "Shared project compartment for web-infra environments."
}
