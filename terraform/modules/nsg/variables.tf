// Inputs accepted by the reusable OCI NSG module.
variable "compartment_id" {
  description = "OCID of the compartment where the NSG will be created."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN where the NSG will be created."
  type        = string
}

variable "display_name" {
  description = "Display name for the NSG."
  type        = string
}
