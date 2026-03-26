// Inputs accepted by the reusable OCI network module.
variable "compartment_id" {
  description = "OCID of the compartment where the network resources will be created."
  type        = string
}

variable "name_prefix" {
  description = "Base name prefix for network resources."
  type        = string
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN."
  type        = string
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN."
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet."
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
