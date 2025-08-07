##################################################
# Public Security List
##################################################

resource "oci_core_security_list" "pub_security_list" {
  display_name = "${var.pub_dns}_security_list-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# MGMT Security List
##################################################

resource "oci_core_security_list" "mgmt_security_list" {
  display_name = "${var.mgmt_dns}_security_list-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# App Security List
##################################################

resource "oci_core_security_list" "app_security_list" {
  display_name = "${var.app_dns}_security_list-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# DB Security List
##################################################

resource "oci_core_security_list" "db_security_list" {
  display_name = "${var.db_dns}_security_list-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# Stage Security List
##################################################

resource "oci_core_security_list" "stg_security_list" {
  display_name = "${var.stg_dns}_security_list-${var.compartment_name}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}