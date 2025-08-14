resource "oci_core_subnet" "subnet" {
  for_each = var.envs
  # availability_domain = ""
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  cidr_block = cidrsubnet(var.vcn_net, each.value.bits, each.value.net)
  display_name = "${var.compartment_name}_subnet_${each.key}"
  dns_label = each.key
  route_table_id = oci_core_route_table.route_table[each.key].id
}