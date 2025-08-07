resource "oci_core_route_table" "mgmt_route_table" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "${var.mgmt_dns}_route_table-${var.compartment_name}"

  route_rules {
    destination = var.route_default
    network_entity_id = oci_core_internet_gateway.internet-gw.id
  }

  route_rules {
    destination = var.svc_gw_storage
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.service-gw.id
  }
}