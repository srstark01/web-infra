// Reusable building block for creating exactly one OCI compartment.
resource "oci_identity_compartment" "this" {
  // OCI needs to know which existing tenancy or compartment will own this one.
  compartment_id = var.parent_compartment_id
  name           = var.name
  description    = var.description

  // Allow Terraform to destroy the compartment if this module is removed.
  enable_delete  = var.enable_delete
}
