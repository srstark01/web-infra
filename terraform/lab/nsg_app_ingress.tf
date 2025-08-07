resource "oci_core_network_security_group_security_rule" "app_ssh_in_from_mgmt" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "SSH Inbound from MGMT"
    protocol = 6
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

resource "oci_core_network_security_group_security_rule" "app_icmp_in_from_mgmt" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "ICMP Inbound from MGMT"
    protocol = 1
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
}

resource "oci_core_network_security_group_security_rule" "app_8000_in_from_mgmt" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "8000 Inbound from MGMT"
    protocol = 6
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

resource "oci_core_network_security_group_security_rule" "app_8000_in_from_pub" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "8000 Inbound from PUB"
    protocol = 6
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.pub_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

resource "oci_core_network_security_group_security_rule" "app_ssh_in_from_bastian" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "SSH inbound from Bastion"
    protocol = 6
    source_type = "CIDR_BLOCK"
    source = "${oci_bastion_bastion.app_bastion.private_endpoint_ip_address}/32"
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}