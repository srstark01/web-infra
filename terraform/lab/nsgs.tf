resource "oci_core_network_security_group" "mgmt_nsg" {
  display_name = "${var.mgmt_dns}_nsg-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group" "app_nsg" {
  display_name = "${var.app_dns}_nsg-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group" "pub_nsg" {
  display_name = "${var.pub_dns}_nsg-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group" "stg_nsg" {
  display_name = "${var.stg_dns}_nsg-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}