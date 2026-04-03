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

variable "app_instance_001_private_ip_last_octet" {
  description = "Host octet to use when assigning the fixed private IP for app-001 within the production subnet."
  type        = number

  validation {
    condition     = var.app_instance_001_private_ip_last_octet >= 1 && var.app_instance_001_private_ip_last_octet <= 254
    error_message = "app_instance_001_private_ip_last_octet must be between 1 and 254."
  }
}

variable "app_instance_002_private_ip_last_octet" {
  description = "Host octet to use when assigning the fixed private IP for app-002 within the production subnet."
  type        = number

  validation {
    condition     = var.app_instance_002_private_ip_last_octet >= 1 && var.app_instance_002_private_ip_last_octet <= 254
    error_message = "app_instance_002_private_ip_last_octet must be between 1 and 254."
  }
}

// Autonomous Database configuration.
variable "adb_display_name" {
  description = "Optional display name override for the Autonomous Database. If null, a name is derived from the environment naming pattern."
  type        = string
  default     = null
}

variable "adb_name" {
  description = "Optional database name override for the Autonomous Database. If null, a short alphanumeric name is derived from the environment naming pattern."
  type        = string
  default     = null
}

variable "adb_admin_password_length" {
  description = "Generated length for the Autonomous Database admin password secret."
  type        = number
  default     = 24
}

variable "adb_wallet_password_length" {
  description = "Generated length for the Autonomous Database wallet password secrets."
  type        = number
  default     = 24
}

variable "adb_workload" {
  description = "Workload type for the Autonomous Database."
  type        = string
  default     = "OLTP"

  validation {
    condition     = contains(["OLTP", "DW", "AJD", "APEX"], var.adb_workload)
    error_message = "adb_workload must be one of \"OLTP\", \"DW\", \"AJD\", or \"APEX\"."
  }
}

variable "adb_version" {
  description = "Database version for the Autonomous Database."
  type        = string
  default     = "23ai"
}

variable "adb_is_free_tier" {
  description = "Whether to create the Autonomous Database as an Always Free instance."
  type        = bool
  default     = true
}

variable "adb_license_model" {
  description = "License model for the Autonomous Database."
  type        = string
  default     = "LICENSE_INCLUDED"

  validation {
    condition     = contains(["LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], var.adb_license_model)
    error_message = "adb_license_model must be either \"LICENSE_INCLUDED\" or \"BRING_YOUR_OWN_LICENSE\"."
  }
}

variable "vault_display_name" {
  description = "Optional display name override for the environment vault."
  type        = string
  default     = null
}

variable "vault_type" {
  description = "Vault type for the environment vault."
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "VIRTUAL_PRIVATE"], var.vault_type)
    error_message = "vault_type must be either \"DEFAULT\" or \"VIRTUAL_PRIVATE\"."
  }
}

variable "vault_key_display_name" {
  description = "Optional display name override for the environment vault master key."
  type        = string
  default     = null
}

variable "vault_key_algorithm" {
  description = "Algorithm used for the environment vault master key."
  type        = string
  default     = "AES"
}

variable "vault_key_length" {
  description = "Length in bytes for the environment vault master key."
  type        = number
  default     = 32
}

variable "vault_key_protection_mode" {
  description = "Protection mode for the environment vault master key."
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["HSM", "SOFTWARE"], var.vault_key_protection_mode)
    error_message = "vault_key_protection_mode must be either \"HSM\" or \"SOFTWARE\"."
  }
}

variable "vault_key_is_auto_rotation_enabled" {
  description = "Whether automatic rotation is enabled for the environment vault master key."
  type        = bool
  default     = false
}

variable "local_public_IP" {
  description = "Trusted public CIDR allowed to reach the management instance."
  type        = string
}

variable "stage_abidex_org_hostname" {
  description = "Hostname served by the staging load balancer for the primary staging site."
  type        = string
  default     = "stage.abidex.org"
}

variable "stage_shawnstark_net_hostname" {
  description = "Hostname served by the staging load balancer for the secondary staging site."
  type        = string
  default     = "stage.shawnstark.net"
}

variable "abidex_org_hostname" {
  description = "Hostname served by the load balancer for the primary production site."
  type        = string
  default     = "abidex.org"
}

variable "shawnstark_net_hostname" {
  description = "Hostname served by the load balancer for the secondary production site."
  type        = string
  default     = "shawnstark.net"
}

variable "load_balancer_shape" {
  description = "OCI shape for the staging load balancer."
  type        = string
  default     = "flexible"
}

variable "load_balancer_min_bandwidth_mbps" {
  description = "Minimum bandwidth in Mbps for the flexible staging load balancer."
  type        = number
  default     = 10
}

variable "load_balancer_max_bandwidth_mbps" {
  description = "Maximum bandwidth in Mbps for the flexible staging load balancer."
  type        = number
  default     = 10
}

variable "load_balancer_health_check_path" {
  description = "HTTPS health check path used by the staging load balancer backends."
  type        = string
  default     = "/home"
}

variable "load_balancer_certificate_name" {
  description = "Existing certificate name to bind to the staging load balancer HTTPS listeners."
  type        = string
  default     = "staging_live_cert"
}

variable "load_balancer_certificate_mode" {
  description = "Certificate mode for the staging LB: bootstrap uses a temporary self-signed cert, external uses an existing OCI LB cert bundle, and auto prefers the external cert when present and otherwise falls back to bootstrap."
  type        = string
  default     = "auto"

  validation {
    condition     = contains(["bootstrap", "external", "auto"], var.load_balancer_certificate_mode)
    error_message = "load_balancer_certificate_mode must be one of \"bootstrap\", \"external\", or \"auto\"."
  }
}
