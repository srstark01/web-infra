resource "oci_identity_compartment" "compartment" {
    # Required
    compartment_id = var.ocid_tenancy
    description = "A compartment for ${var.compartment_name}}"
    name = var.compartment_name

    # Optional
    enable_delete = "true"
}