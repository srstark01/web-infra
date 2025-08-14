resource "oci_core_network_security_group" "nsg" {
  for_each = var.envs
  display_name = "${var.compartment_name}_nsg_${each.key}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group_security_rule" "rule" {
  for_each = {
    for pair in flatten([
      for env_name, env in var.envs : [
        for idx, rule in env.nsg_rules : {
          key   = format("%s:%s", env_name, coalesce(rule.name, tostring(idx + 1)))
          value = { env = env_name, rule = rule }
        }
      ]
    ]) : pair.key => pair.value
  }

  network_security_group_id = oci_core_network_security_group.nsg[each.value.env].id

  direction    = each.value.rule.direction
  description  = split(":", each.key)[1]

  protocol = (
    each.value.rule.protocol == -1
    ? "all"
    : tostring(each.value.rule.protocol)
  )

  source_type      = each.value.rule.source_type
  source = (
    each.value.rule.source_type == "NETWORK_SECURITY_GROUP"
      ? oci_core_network_security_group.nsg[each.value.rule.source].id
      : each.value.rule.source
  )

  destination_type = each.value.rule.destination_type
  destination = (
    each.value.rule.destination_type == "NETWORK_SECURITY_GROUP"
      ? oci_core_network_security_group.nsg[each.value.rule.destination].id
      : each.value.rule.destination
  )

  dynamic "tcp_options" {
    for_each = each.value.rule.tcp_destination_port_min != null ? [1] : []
    content {
      destination_port_range {
        min = each.value.rule.tcp_destination_port_min
        max = each.value.rule.tcp_destination_port_max
      }
    }
  }

  dynamic "udp_options" {
    for_each = each.value.rule.udp_destination_port_min != null ? [1] : []
    content {
      destination_port_range {
        min = each.value.rule.udp_destination_port_min
        max = each.value.rule.udp_destination_port_max
      }
    }
  }
}