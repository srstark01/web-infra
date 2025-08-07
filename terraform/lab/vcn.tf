##################################################
# Core Network
##################################################

resource "oci_core_virtual_network" "vcn" {
  compartment_id = oci_identity_compartment.compartment.id
  cidr_block = var.vcn_net
  dns_label = "${var.vcn_dns}${var.compartment_name}"
  display_name = "${var.vcn_dns}${var.compartment_name}"
}

##################################################
# Internet Gateway
##################################################

resource "oci_core_internet_gateway" "internet-gw" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name = "${var.vcn_dns}${var.compartment_name}_internet-gw"
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# NAT Gateway
##################################################

resource "oci_core_nat_gateway" "nat-gw" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name = "${var.vcn_dns}${var.compartment_name}_nat-gw"
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# Service Gateway
##################################################

resource "oci_core_service_gateway" "service-gw" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name = "${var.vcn_dns}${var.compartment_name}_service-gw"
  vcn_id = oci_core_virtual_network.vcn.id

  services {
    service_id = data.oci_core_services.services.services.0.id
  }
}