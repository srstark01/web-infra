// Inputs accepted by the reusable OCI instance module.
variable "availability_domain" {
  description = "Availability domain where the instance will be launched."
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment where the instance will be created."
  type        = string
}

variable "display_name" {
  description = "Display name for the instance."
  type        = string
}

variable "shape" {
  description = "OCI compute shape for the instance."
  type        = string
}

variable "shape_config" {
  description = "Optional flexible shape configuration."
  type = object({
    memory_in_gbs = number
    ocpus         = number
  })
  default = null
}

variable "preserve_boot_volume" {
  description = "Whether to preserve the boot volume when the instance is destroyed."
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet OCID for the primary VNIC."
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the primary VNIC."
  type        = bool
  default     = false
}

variable "hostname_label" {
  description = "DNS hostname label for the primary VNIC."
  type        = string
}

variable "nsg_ids" {
  description = "Optional NSG OCIDs to attach to the primary VNIC."
  type        = list(string)
  default     = []
}

variable "ssh_authorized_keys" {
  description = "SSH public key content to place into authorized_keys."
  type        = string
}

variable "metadata" {
  description = "Additional instance metadata entries."
  type        = map(string)
  default     = {}
}

variable "image_id" {
  description = "Pinned OCI image OCID used to boot the instance."
  type        = string
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GB."
  type        = number
  default     = 50
}
