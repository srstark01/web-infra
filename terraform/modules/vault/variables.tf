// Inputs accepted by the reusable OCI vault module.
variable "compartment_id" {
  description = "OCID of the compartment where the vault, key, and secrets will be created."
  type        = string
}

variable "vault_display_name" {
  description = "Display name for the KMS vault."
  type        = string
}

variable "vault_type" {
  description = "Vault type for the OCI KMS vault."
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "VIRTUAL_PRIVATE"], var.vault_type)
    error_message = "vault_type must be either \"DEFAULT\" or \"VIRTUAL_PRIVATE\"."
  }
}

variable "key_display_name" {
  description = "Display name for the KMS master key used to encrypt the secrets."
  type        = string
}

variable "key_algorithm" {
  description = "Algorithm used for the KMS key."
  type        = string
  default     = "AES"
}

variable "key_length" {
  description = "Length of the KMS key in bytes."
  type        = number
  default     = 32
}

variable "key_protection_mode" {
  description = "Protection mode for the KMS key."
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["HSM", "SOFTWARE"], var.key_protection_mode)
    error_message = "key_protection_mode must be either \"HSM\" or \"SOFTWARE\"."
  }
}

variable "key_is_auto_rotation_enabled" {
  description = "Whether automatic key rotation is enabled for the KMS key."
  type        = bool
  default     = false
}

variable "secrets" {
  description = "Secrets to create in the vault, keyed by OCI secret name."
  type = map(object({
    description         = optional(string, null)
    auto_generate       = optional(bool, true)
    passphrase_length   = optional(number, 24)
    generation_template = optional(string, "DBAAS_DEFAULT_PASSWORD")
  }))
  sensitive = true
}
