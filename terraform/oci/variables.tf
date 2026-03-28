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

// Management instance configuration.
variable "management_availability_domain" {
  description = "Optional explicit availability domain for the management instance. If null, the first AD in the region is used."
  type        = string
  default     = null
}

variable "management_shape" {
  description = "OCI compute shape for the management instance."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "management_shape_ocpus" {
  description = "OCPU count for the management instance flexible shape."
  type        = number
  default     = 1
}

variable "management_shape_memory_in_gbs" {
  description = "Memory in GB for the management instance flexible shape."
  type        = number
  default     = 6
}

variable "management_os" {
  description = "Operating system name used to resolve the management instance image."
  type        = string
  default     = "Oracle Linux"
}

variable "management_os_version" {
  description = "Operating system version used to resolve the management instance image."
  type        = string
  default     = "9"
}

variable "management_boot_volume_size_in_gbs" {
  description = "Boot volume size in GB for the management instance."
  type        = number
  default     = 50
}

variable "management_ssh_authorized_keys_path" {
  description = "Path to the SSH public key that should be installed on the management instance."
  type        = string
}

variable "management_instance_001_private_ip_last_octet" {
  description = "Host octet to use when assigning the fixed private IP for mgmt-001 within the public subnet."
  type        = number

  validation {
    condition     = var.management_instance_001_private_ip_last_octet >= 1 && var.management_instance_001_private_ip_last_octet <= 254
    error_message = "management_instance_001_private_ip_last_octet must be between 1 and 254."
  }
}

variable "staging_instance_001_private_ip_last_octet" {
  description = "Host octet to use when assigning the fixed private IP for stg-001 within the staging subnet."
  type        = number

  validation {
    condition     = var.staging_instance_001_private_ip_last_octet >= 1 && var.staging_instance_001_private_ip_last_octet <= 254
    error_message = "staging_instance_001_private_ip_last_octet must be between 1 and 254."
  }
}

variable "local_public_IP" {
  description = "Trusted public CIDR allowed to reach the management instance."
  type        = string
}
