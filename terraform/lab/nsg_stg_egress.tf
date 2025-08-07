resource "oci_core_network_security_group_security_rule" "stg_https_out" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "EGRESS"
    description = "HTTPS Outbound"
    protocol = 6
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
    tcp_options {
        destination_port_range {
            max = 443
            min = 443
        }
    }
}

resource "oci_core_network_security_group_security_rule" "stg_http_out" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "EGRESS"
    description = "HTTP Outbound"
    protocol = 6
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}