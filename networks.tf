##################################################
# Public Subnet
##################################################

resource "oci_core_subnet" "pub_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_cidr, 8, 1)
  display_name = var.pub_dns_label
  dns_label = var.pub_dns_label
  route_table_id = oci_core_route_table.pub_rt.id
  security_list_ids = [oci_core_security_list.securitylistPub.id]
}

##################################################
# MGMT Subnet
##################################################

resource "oci_core_subnet" "mgmt_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_cidr, 8, 0)
  display_name = var.mgmt_dns_label
  dns_label = var.mgmt_dns_label
  route_table_id = oci_core_route_table.mgmt_rt.id
  security_list_ids = [oci_core_security_list.mgmt_security_list.id]
}

##################################################
# App Subnet
##################################################

resource "oci_core_subnet" "app_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_cidr, 8, 2)
  display_name = var.app_dns_label
  dns_label = var.app_dns_label
  route_table_id = oci_core_route_table.app_rt.id
  security_list_ids = [oci_core_security_list.securitylistApp.id]
  prohibit_public_ip_on_vnic = "true"
}

##################################################
# DB Subnet
##################################################

resource "oci_core_subnet" "db_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_cidr, 8, 3)
  display_name = var.db_dns_label
  dns_label = var.db_dns_label
  route_table_id = oci_core_route_table.db_rt.id
  security_list_ids = [oci_core_security_list.securitylistDB.id]
  prohibit_public_ip_on_vnic = "true"
}
