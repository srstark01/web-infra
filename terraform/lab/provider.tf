provider "oci" {
  tenancy_ocid = var.ocid_tenancy
  user_ocid = var.ocid_user 
  private_key_path = var.oci_private_key
  fingerprint = var.fingerprint
  region = var.region
}