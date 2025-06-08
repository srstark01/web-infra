# Data from terraform.tfvars file
variable "mypubIP" {}
variable "mgmt001" {}
variable "app001" {}
variable "app002" {}
variable "user" {}
variable "ssh_private_key" {}
variable "ssh_public_key" {}
variable "ssh_public_key_cloud-shell" {}

# Choose an Availability Domain

variable "AD1" {
  default = "3"
}

variable "AD2" {
  default = "2"
}

variable "AD3" {
  default = "3"
}

variable "tenancy_ocid" {
  description = "The OCID of your tenancy."
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user calling the API."
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint for the user's API signing key."
  type        = string
}

variable "private_key_path" {
  description = "The full path to the user's private key file."
  type        = string
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "The OCI region to deploy resources in."
  type        = string
  default     = "us-phoenix-1"
}

# OS Images

variable "image_operating_system" {
  default = "Canonical Ubuntu"
}

variable "image_operating_system_version" {
  default = "24.04"
}

# Compute Shape

variable "instance_shape" {
  description = "Instance Shape"
  default = "VM.Standard.A1.Flex"
}

# VCN Variables

variable "vcn_cidr" {
  default = "10.10.0.0/16"
}

variable "vcn_dns_label" {
  description = "VCN DNS label"
  default = "shawnstark"
}

variable "pub_dns_label" {
  description = "Public Subnet DNS Label"
  default = "pub"
}

variable "mgmt_dns_label" {
  description = "MGMT Subnet DNS Label"
  default = "mgmt"
}

variable "app_dns_label" {
  description = "App Subnet DNS Label"
  default = "app"
}

variable "db_dns_label" {
  description = "DB Subnet DNS Label"
  default = "db"
}

variable "default_route" {
  default = "0.0.0.0/0"
}

variable "svc_gw_storage" {
  default = "oci-phx-objectstorage"
}

variable "svc_gw_all" {
  default = "all-phx-services-in-oracle-services-network"
}