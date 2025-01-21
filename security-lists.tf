##################################################
# Public Security List
##################################################

resource "oci_core_security_list" "securitylistPub" {
  display_name = "SL_pub"
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# MGMT Security List
##################################################

resource "oci_core_security_list" "mgmt_security_list" {
  display_name = "SL_mgmt"
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# App Security List
##################################################

resource "oci_core_security_list" "securitylistApp" {
  display_name = "SL_app"
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# DB Security List
##################################################

resource "oci_core_security_list" "securitylistDB" {
  display_name = "SL_db"
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}
