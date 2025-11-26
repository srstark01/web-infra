# resource "oci_core_network_security_group" "nsg" {
#   for_each = var.envs
#   display_name = "${var.compartment_name}_nsg_${each.key}"
#   compartment_id = oci_identity_compartment.compartment.id
#   vcn_id = oci_core_virtual_network.vcn.id
# }

# resource "oci_core_network_security_group_security_rule" "rule" {
#   for_each = {
#     for pair in flatten([
#       for env_name, env in var.envs : [
#         for idx, rule in env.nsg_rules : {
#           key   = format("%s:%s", env_name, coalesce(rule.name, tostring(idx + 1)))
#           value = { env = env_name, rule = rule }
#         }
#       ]
#     ]) : pair.key => pair.value
#   }

#   network_security_group_id = oci_core_network_security_group.nsg[each.value.env].id

#   direction    = each.value.rule.direction
#   description  = split(":", each.key)[1]

#   protocol = (
#     each.value.rule.protocol == -1
#     ? "all"
#     : tostring(each.value.rule.protocol)
#   )

#   source_type      = each.value.rule.source_type
#   source = (
#     each.value.rule.source_type == "NETWORK_SECURITY_GROUP"
#       ? oci_core_network_security_group.nsg[each.value.rule.source].id
#       : each.value.rule.source
#   )

#   destination_type = each.value.rule.destination_type
#   destination = (
#     each.value.rule.destination_type == "NETWORK_SECURITY_GROUP"
#       ? oci_core_network_security_group.nsg[each.value.rule.destination].id
#       : each.value.rule.destination
#   )

#   dynamic "tcp_options" {
#     for_each = each.value.rule.tcp_destination_port_min != null ? [1] : []
#     content {
#       destination_port_range {
#         min = each.value.rule.tcp_destination_port_min
#         max = each.value.rule.tcp_destination_port_max
#       }
#     }
#   }

#   dynamic "udp_options" {
#     for_each = each.value.rule.udp_destination_port_min != null ? [1] : []
#     content {
#       destination_port_range {
#         min = each.value.rule.udp_destination_port_min
#         max = each.value.rule.udp_destination_port_max
#       }
#     }
#   }
# }

##################################################
# MGMT Network Security Group
##################################################

resource "oci_core_network_security_group" "mgmt_nsg" {
  display_name = "${var.compartment_name}_nsg_${var.mgmt_dns}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

### MGMT - L2 Inbound Allow All ###
resource "oci_core_network_security_group_security_rule" "mgmt_l2_inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "L2-inbound"
    protocol = "all"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
}

### MGMT - L2 Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "mgmt_l2_outbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "L2-outbound"
    protocol = "all"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.mgmt_nsg.id
}

### MGMT - ICMP Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "mgmt_icmp_outbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "ICMP-outbound"
    protocol = "1"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
}

### MGMT - ICMP Inbound from STG ###
resource "oci_core_network_security_group_security_rule" "mgmt_stg_icmp_inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "ICMP-stg-inbound"
    protocol = "1"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.stg_nsg.id
}

### MGMT - ICMP Inbound from APP ###
resource "oci_core_network_security_group_security_rule" "mgmt_app_icmp_inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "ICMP-app-inbound"
    protocol = "1"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.app_nsg.id
}

### MGMT - HTTP Outbound All ###
resource "oci_core_network_security_group_security_rule" "mgmt_http_outbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "HTTP-outbound"
    protocol = "6"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}

### MGMT - HTTPS Outbound All ###
resource "oci_core_network_security_group_security_rule" "mgmt_https_outbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "HTTPS-outbound"
    protocol = "6"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
    tcp_options {
        destination_port_range {
            max = 443
            min = 443
        }
    }
}

### MGMT - SSH Outbound All ###
resource "oci_core_network_security_group_security_rule" "mgmt_ssh_outbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "ssh-outbound"
    protocol = "6"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

### MGMT - SQL Outbound All ###
resource "oci_core_network_security_group_security_rule" "mgmt_sql_outbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "sql-outbound"
    protocol = "6"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
    tcp_options {
        destination_port_range {
            max = 1522
            min = 1522
        }
    }
}


### MGMT - SQL Inbound from STG ###
resource "oci_core_network_security_group_security_rule" "mgmt_stg_sql_inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "sql-stg-inbound"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.stg_nsg.id
    tcp_options {
        destination_port_range {
            max = 1522
            min = 1522
        }
    }
}

### MGMT - SQL Inbound from APP ###
resource "oci_core_network_security_group_security_rule" "mgmt_app_sql_inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "sql-app-inbound"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.app_nsg.id
    tcp_options {
        destination_port_range {
            max = 1522
            min = 1522
        }
    }
}

### MGMT - ICMP Inbound from All ###
resource "oci_core_network_security_group_security_rule" "mgmt-local-icmp-inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "local-icmp-inbound"
    protocol = "1"
    source_type = "CIDR_BLOCK"
    source = var.default_route
}

### MGMT - SSH Inbound from Local ###
resource "oci_core_network_security_group_security_rule" "mgmt-local-ssh-inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "local-ssh-inbound"
    protocol = "6"
    source_type = "CIDR_BLOCK"
    source = var.local_pub_ip
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

### MGMT - STG Web Apps Outbound ###
resource "oci_core_network_security_group_security_rule" "mgmt_stg_web_outbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "stg-web-outbound"
    protocol = "6"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.stg_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

### MGMT - APP Web Apps Outbound ###
resource "oci_core_network_security_group_security_rule" "mgmt_app_web_outbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "EGRESS"
    description = "app-web-outbound"
    protocol = "6"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.app_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

### MGMT - Jenkins Inbound from PUB ###
resource "oci_core_network_security_group_security_rule" "mgmt_pub_jenkins_inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "jenkins-inbound"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.pub_nsg.id
    tcp_options {
        destination_port_range {
            max = 8080
            min = 8080
        }
    }
}

### MGMT - VPN Inbound from PUB ###
resource "oci_core_network_security_group_security_rule" "mgmt_pub_vpn_inbound" {
    network_security_group_id = oci_core_network_security_group.mgmt_nsg.id
    direction = "INGRESS"
    description = "vpn-inbound"
    protocol = "17"
    source_type = "CIDR_BLOCK"
    source = var.default_route
    udp_options {
        destination_port_range {
            max = 51820
            min = 51820
        }
    }
}


##################################################
# STG Network Security Group
##################################################

resource "oci_core_network_security_group" "stg_nsg" {
  display_name = "${var.compartment_name}_nsg_${var.stg_dns}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

### STG - L2 Inbound Allow All ###
resource "oci_core_network_security_group_security_rule" "stg_l2_inbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "INGRESS"
    description = "L2-inbound"
    protocol = "all"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.stg_nsg.id
}

### STG - L2 Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "stg_l2_outbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "EGRESS"
    description = "L2-outbound"
    protocol = "all"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.stg_nsg.id
}

### STG - ICMP Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "stg_icmp_outbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "EGRESS"
    description = "ICMP-outbound"
    protocol = "1"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
}

### STG - HTTP Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "stg_http_outbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "EGRESS"
    description = "HTTP-outbound"
    protocol = "6"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}

### STG - HTTPS Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "stg_https_outbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "EGRESS"
    description = "HTTPS-outbound"
    protocol = "6"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
    tcp_options {
        destination_port_range {
            max = 443
            min = 443
        }
    }
}

### STG - ICMP Inbound from MGMT ###
resource "oci_core_network_security_group_security_rule" "stg-mgmt-icmp-inbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "INGRESS"
    description = "mgmt-icmp"
    protocol = "1"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
}

### STG - SSH Inbound from MGMT ###
resource "oci_core_network_security_group_security_rule" "stg-mgmt-ssh-inbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "INGRESS"
    description = "mgmt-ssh"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

### STG - Web App Inbound from MGMT ###
resource "oci_core_network_security_group_security_rule" "stg-mgmt-web-inbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "INGRESS"
    description = "mgmt-web"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

### STG - Web App Inbound from PUB ###
resource "oci_core_network_security_group_security_rule" "stg-pub-web-inbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "INGRESS"
    description = "pub-web"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.pub_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

### STG - SQL Outbound to MGMT ###
resource "oci_core_network_security_group_security_rule" "stg_mgmt_sql_outbound" {
    network_security_group_id = oci_core_network_security_group.stg_nsg.id
    direction = "EGRESS"
    description = "sql-mgmt-outbound"
    protocol = "6"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 1522
            min = 1522
        }
    }
}


##################################################
# APP Network Security Group
##################################################

resource "oci_core_network_security_group" "app_nsg" {
  display_name = "${var.compartment_name}_nsg_${var.app_dns}"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

### APP - L2 Inbound Allow All ###
resource "oci_core_network_security_group_security_rule" "app_l2_inbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "L2-inbound"
    protocol = "all"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.app_nsg.id
}

### APP - L2 Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "app_l2_outbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "EGRESS"
    description = "L2-outbound"
    protocol = "all"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.app_nsg.id
}

### APP - ICMP Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "app_icmp_outbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "EGRESS"
    description = "ICMP-outbound"
    protocol = "1"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
}

### APP - HTTP Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "app_http_outbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "EGRESS"
    description = "HTTP-outbound"
    protocol = "6"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}

### APP - HTTPS Outbound Allow All ###
resource "oci_core_network_security_group_security_rule" "app_https_outbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "EGRESS"
    description = "HTTPS-outbound"
    protocol = "6"
    destination_type = "CIDR_BLOCK"
    destination = var.default_route
    tcp_options {
        destination_port_range {
            max = 443
            min = 443
        }
    }
}

### APP - ICMP Inbound from MGMT ###
resource "oci_core_network_security_group_security_rule" "app-mgmt-icmp-inbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "mgmt-icmp"
    protocol = "1"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
}

### APP - SSH Inbound from MGMT ###
resource "oci_core_network_security_group_security_rule" "app-mgmt-ssh-inbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "mgmt-ssh"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

### APP - Web App Inbound from MGMT ###
resource "oci_core_network_security_group_security_rule" "app-mgmt-web-inbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "mgmt-web"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

### APP - Web App Inbound from PUB ###
resource "oci_core_network_security_group_security_rule" "app-pub-web-inbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "INGRESS"
    description = "pub-web"
    protocol = "6"
    source_type = "NETWORK_SECURITY_GROUP"
    source = oci_core_network_security_group.pub_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

### APP - SQL Inbound from MGMT ###
resource "oci_core_network_security_group_security_rule" "app_mgmt_sql_outbound" {
    network_security_group_id = oci_core_network_security_group.app_nsg.id
    direction = "EGRESS"
    description = "sql-mgmt-outbound"
    protocol = "6"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 1522
            min = 1522
        }
    }
}

##################################################
# Pub Network Security Group
##################################################

resource "oci_core_network_security_group" "pub_nsg" {
  display_name = "${var.compartment_name}_nsg_pub"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
}

### PUB - HTTP Inbound Allow All ###
resource "oci_core_network_security_group_security_rule" "pub-http-inbound" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "INGRESS"
    description = "http-inbound"
    protocol = "6"
    source_type = "CIDR_BLOCK"
    source = var.default_route
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
}

### PUB - Web App Outbound to STG ###
resource "oci_core_network_security_group_security_rule" "pub_stg_web_outbound" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "EGRESS"
    description = "stg-web-outbound"
    protocol = "6"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.stg_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

### PUB - Web App Outbound to APP ###
resource "oci_core_network_security_group_security_rule" "pub_app_web_outbound" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "EGRESS"
    description = "app-web-outbound"
    protocol = "6"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.app_nsg.id
    tcp_options {
        destination_port_range {
            max = 8001
            min = 8000
        }
    }
}

### PUB - Web App Outbound to Jenkins ###
resource "oci_core_network_security_group_security_rule" "pub_app_jenkins_outbound" {
    network_security_group_id = oci_core_network_security_group.pub_nsg.id
    direction = "EGRESS"
    description = "app-jenkins-outbound"
    protocol = "6"
    destination_type = "NETWORK_SECURITY_GROUP"
    destination = oci_core_network_security_group.mgmt_nsg.id
    tcp_options {
        destination_port_range {
            max = 8080
            min = 8080
        }
    }
}