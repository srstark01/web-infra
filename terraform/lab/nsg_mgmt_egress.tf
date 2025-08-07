resource "oci_core_network_security_group_security_rule" "mgmt_ssh_out_to_app" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "SSH Outbound to APP"
    protocol = 6
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.app_nsg.id
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_web_out_to_app" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "Web Outbound to APP"
    protocol = 6
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.app_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_icmp_out_to_app" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "ICMP Outbound to APP"
    protocol = 1
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.app_nsg.id
}

resource "oci_core_network_security_group_security_rule" "mgmt_http_out" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
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

resource "oci_core_network_security_group_security_rule" "mgmt_https_out" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
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

resource "oci_core_network_security_group_security_rule" "outbound_to_l2" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "L2 Outbound"
    protocol = "all"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.mgmt_nsg.id
}

resource "oci_core_network_security_group_security_rule" "mgmt_ssh_out_to_stg" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "SSH Outbound to Stage"
    protocol = 6
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.stg_nsg.id
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_web_out_to_stg" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "Web Outbound to Stage"
    protocol = 6
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.stg_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_icmp_out_to_stg" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "ICMP Outbound to Stage"
    protocol = 1
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.stg_nsg.id
}