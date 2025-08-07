resource "oci_core_network_security_group_security_rule" "mgmt_ssh_in_from_local" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "SSH inbound from local"
    protocol = 6
    source_type = "CIDR_BLOCK"
    source = var.local_pub_ip
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_8080_in_from_local" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "8080 inbound from local to Jenkins"
    protocol = 6
    source_type = "CIDR_BLOCK"
    source = var.local_pub_ip
    tcp_options {
        destination_port_range {
            max = 8080
            min = 8080
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_icmp_in_from_local" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "ICMP inbound from local"
    protocol = 1
    source_type = "CIDR_BLOCK"
    source = var.local_pub_ip
}

resource "oci_core_network_security_group_security_rule" "mgmt_ssh_in_from_bastian" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "SSH inbound from Bastion"
    protocol = 6
    source_type = "CIDR_BLOCK"
    source = "${oci_bastion_bastion.mgmt_bastion.private_endpoint_ip_address}/32"
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

resource "oci_core_network_security_group_security_rule" "inbound_from_l2" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "L2 Inbound"
    protocol = "all"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
}

resource "oci_core_network_security_group_security_rule" "mgmt_8080_in_from_pub" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "8080 inbound from pub to Jenkins"
    protocol = 6
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.pub_nsg.id
    tcp_options {
        destination_port_range {
            max = 8080
            min = 8080
        }
    }
}