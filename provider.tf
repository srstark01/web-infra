# provider.tf

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy-ocid
  user_ocid = var.user-ocid 
  private_key_path = var.private-key-path
  fingerprint = var.fingerprint
  region = var.region
}
