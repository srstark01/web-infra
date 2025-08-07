resource "oci_core_route_table" "pub_route_table" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "${var.pub_dns}_route_table-${var.compartment_name}"

  route_rules {
    destination = var.route_default
    network_entity_id = oci_core_internet_gateway.internet-gw.id
  }
}