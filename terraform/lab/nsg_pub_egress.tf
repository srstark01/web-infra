resource "oci_core_network_security_group_security_rule" "pub_web_to_app" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "EGRESS"
    description = "Web to App"
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

resource "oci_core_network_security_group_security_rule" "pub_web_to_stg" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "EGRESS"
    description = "Web to stg"
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

resource "oci_core_network_security_group_security_rule" "pub_web_to_jenkins_mgmt" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "EGRESS"
    description = "Web to Jenkins mgmt"
    protocol = 6
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 8080
            min = 8080
        }
    }
}