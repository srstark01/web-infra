resource "oci_core_security_list" "pub_security_list" {
  for_each = var.envs
  display_name = "${var.compartment_name}_security-list_${each.key}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}