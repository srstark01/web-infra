##################################################
# Core Network
##################################################

resource "oci_core_virtual_network" "vcn" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  cidr_block = var.vcn_cidr
  dns_label = var.vcn_dns_label
  display_name = var.vcn_dns_label
}

##################################################
# Internet Gateway
##################################################

resource "oci_core_internet_gateway" "igw" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  display_name = "${var.vcn_dns_label}_igw"
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# NAT Gateway
##################################################

resource "oci_core_nat_gateway" "ngw" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  display_name = "${var.vcn_dns_label}_ngw"
  vcn_id = oci_core_virtual_network.vcn.id
}

##################################################
# Service Gateway
##################################################

resource "oci_core_service_gateway" "sgw" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  display_name = "${var.vcn_dns_label}_sgw"
  vcn_id = oci_core_virtual_network.vcn.id

  services {
    service_id = data.oci_core_services.services.services.0.id
  }
}
