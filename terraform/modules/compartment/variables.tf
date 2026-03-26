variable "parent_compartment_id" {
  description = "OCID of the parent compartment where this compartment will be created."
  type        = string
}

variable "name" {
  description = "Compartment name."
  type        = string
}

variable "description" {
  description = "Compartment description."
  type        = string
}

variable "enable_delete" {
  description = "Allow Terraform to delete the compartment."
  type        = bool
  default     = true
}
