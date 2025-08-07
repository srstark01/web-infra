resource "oci_core_network_security_group_security_rule" "pub_80_inbound" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "INGRESS"
    description = "80 Inbound"
    protocol = 6
    source_type = "CIDR_BLOCK"
    source = "0.0.0.0/0"
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}