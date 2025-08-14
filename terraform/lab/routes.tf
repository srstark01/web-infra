resource "oci_core_route_table" "route_table" {
  for_each = var.envs

  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "${var.compartment_name}_route-table_${each.key}"

  dynamic "route_rules" {
    for_each = each.value.routes
      content {
        destination = route_rules.value.destination
        destination_type  = route_rules.value.destination_type
        network_entity_id = (
          route_rules.value.network_entity_id == "nat-gw" ? oci_core_nat_gateway.nat-gw.id :
          route_rules.value.network_entity_id == "internet-gw" ? oci_core_internet_gateway.internet-gw.id :
          oci_core_service_gateway.service-gw.id
        )
      }
  }
}