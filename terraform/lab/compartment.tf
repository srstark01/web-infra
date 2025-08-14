resource "oci_identity_compartment" "compartment" {
    compartment_id = var.ocid_tenancy
    description = "A compartment for ${var.compartment_name}}"
    name = "${var.compartment_name}_compartment"
    enable_delete = "true"
}