// OCI provider authentication and targeting values.
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

// Naming inputs for the compartment this stack creates.
variable "project_name" {
  description = "Base project name used in resource naming."
  type        = string
  default     = "web-infra"
}

variable "environment_name" {
  description = "Environment name used in the child compartment name."
  type        = string
}

variable "environment_description" {
  description = "Description for the environment compartment."
  type        = string
}

// Optional override that lets this stack skip remote-state lookup and
// target an already-known parent compartment directly.
variable "parent_compartment_id" {
  description = "Optional existing parent project compartment OCID. If null, the shared stack state output is used."
  type        = string
  default     = null
}

// Local path to the shared stack's state file. This is only used when
// parent_compartment_id is left null.
variable "shared_state_path" {
  description = "Path to the shared stack state file used to discover the parent project compartment OCID."
  type        = string
  default     = "../oci-shared/terraform.tfstate"
}

// Network layout for the environment-local VCN and subnets.
variable "vcn_cidr_block" {
  description = "CIDR block for the environment VCN."
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet that will later host the management instance and load balancer."
  type        = string
}

variable "app_staging_subnet_cidr_block" {
  description = "CIDR block for the private staging application subnet."
  type        = string
}

variable "app_prod_subnet_cidr_block" {
  description = "CIDR block for the private production application subnet."
  type        = string
}
