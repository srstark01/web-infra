##################################################
# Public Subnet
##################################################

resource "oci_core_subnet" "pub_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_net, 8, 0)
  display_name = var.pub_dns
  dns_label = var.pub_dns
  route_table_id = oci_core_route_table.pub_route_table.id
  security_list_ids = [oci_core_security_list.pub_security_list.id]
}

##################################################
# MGMT Subnet
##################################################

resource "oci_core_subnet" "mgmt_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_net, 8, 1)
  display_name = var.mgmt_dns
  dns_label = var.mgmt_dns
  route_table_id = oci_core_route_table.mgmt_route_table.id
  security_list_ids = [oci_core_security_list.mgmt_security_list.id]
}

##################################################
# Stage Subnet
##################################################

resource "oci_core_subnet" "stg_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_net, 8, 2)
  display_name = var.stg_dns
  dns_label = var.stg_dns
  route_table_id = oci_core_route_table.stg_route_table.id
  security_list_ids = [oci_core_security_list.stg_security_list.id]
  prohibit_public_ip_on_vnic = "true"
}

##################################################
# App Subnet
##################################################

resource "oci_core_subnet" "app_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_net, 8, 3)
  display_name = var.app_dns
  dns_label = var.app_dns
  route_table_id = oci_core_route_table.app_route_table.id
  security_list_ids = [oci_core_security_list.app_security_list.id]
  prohibit_public_ip_on_vnic = "true"
}

##################################################
# DB Subnet
##################################################

resource "oci_core_subnet" "db_subnet" {
  availability_domain = ""
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_net, 8, 4)
  display_name = var.db_dns
  dns_label = var.db_dns
  route_table_id = oci_core_route_table.db_route_table.id
  security_list_ids = [oci_core_security_list.db_security_list.id]
  prohibit_public_ip_on_vnic = "true"
}
