##################################################
# MGMT Network Security Group
##################################################

resource "oci_core_network_security_group" "mgmt_nsg" {
  display_name = "mgmt_nsg"
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group_security_rule" "mgmt_ssh_in_from_local" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "SSH inbound from local"
    protocol = 6
    source_type = "CIDR_BLOCK"
    source = var.mypubIP
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

resource "oci_core_network_security_group_security_rule" "jenkins_access_from_local" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "Jenkins access from local"
    protocol = 6
    source_type = "CIDR_BLOCK"
    source = var.mypubIP
    tcp_options {
        destination_port_range {
            max = 8080
            min = 8080
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_ssh_out_to_app" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "SSH outbound to APP"
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

resource "oci_core_network_security_group_security_rule" "mgmt_http_out" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "HTTP outbound"
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
    description = "HTTPS outbound"
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

##################################################
# App Network Security Group
##################################################

resource "oci_core_network_security_group" "app_nsg" {
  display_name = "app_nsg"
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group_security_rule" "app_ssh_in_from_mgmt" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "SSH inbound from MGMT"
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

resource "oci_core_network_security_group_security_rule" "app_http_in_from_mgmt" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "HTTP inbound from MGMT"
    protocol = 6
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}

resource "oci_core_network_security_group_security_rule" "app_http_in_from_pub" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "HTTP inbound from PUB"
    protocol = 6
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.pub_nsg.id
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}

resource "oci_core_network_security_group_security_rule" "app_https_out" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "EGRESS"
    description = "HTTPS outbound"
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

resource "oci_core_network_security_group_security_rule" "app_http_out" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "EGRESS"
    description = "HTTP outbound"
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

##################################################
# Pub Network Security Group
##################################################

resource "oci_core_network_security_group" "pub_nsg" {
  display_name = "pub_nsg"
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

resource "oci_core_network_security_group_security_rule" "pub_http_inbound" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "INGRESS"
    description = "HTTP inbound"
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

resource "oci_core_network_security_group_security_rule" "http_to_app" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "EGRESS"
    description = "HTTP to App"
    protocol = 6
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.app_nsg.id
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}
