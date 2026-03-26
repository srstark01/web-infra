// Reusable OCI network security group building block.
resource "oci_core_network_security_group" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.display_name
}

resource "oci_core_network_security_group_security_rule" "this" {
  for_each = { for index, rule in var.rules : tostring(index) => rule }

  network_security_group_id = oci_core_network_security_group.this.id
  description               = each.value.description
  direction                 = each.value.direction
  protocol                  = each.value.protocol
  stateless                 = each.value.stateless

  source      = each.value.direction == "INGRESS" ? each.value.cidr : null
  source_type = each.value.direction == "INGRESS" ? each.value.cidr_type : null

  destination      = each.value.direction == "EGRESS" ? each.value.cidr : null
  destination_type = each.value.direction == "EGRESS" ? each.value.cidr_type : null

  dynamic "tcp_options" {
    for_each = each.value.tcp_port_range == null ? [] : [each.value.tcp_port_range]

    content {
      destination_port_range {
        min = tcp_options.value.min
        max = tcp_options.value.max
      }
    }
  }
}
