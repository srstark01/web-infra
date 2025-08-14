##################################################
# Core Network
##################################################

resource "oci_core_virtual_network" "vcn" {
  compartment_id = oci_identity_compartment.compartment.id
  cidr_block = var.vcn_net
  dns_label = var.vcn_dns
  display_name = "${var.compartment_name}_vcn_${var.vcn_dns}"
}

##################################################
# Internet Gateway
##################################################

resource "oci_core_internet_gateway" "internet-gw" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name = "${var.compartment_name}_internet-gw_${var.vcn_dns}"
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# NAT Gateway
##################################################

resource "oci_core_nat_gateway" "nat-gw" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name = "${var.compartment_name}_nat-gw_${var.vcn_dns}"
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# Service Gateway
##################################################

resource "oci_core_service_gateway" "service-gw" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name = "${var.compartment_name}_service-gw_${var.vcn_dns}"
  vcn_id = oci_core_virtual_network.vcn.id

  services {
    service_id = data.oci_core_services.services.services.0.id
  }
}