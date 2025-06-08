##################################################
# Public Route Table
##################################################

resource "oci_core_route_table" "pub_rt" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "pub_rt"

  route_rules {
    destination = var.default_route
    network_entity_id = oci_core_internet_gateway.igw.id
  }

  route_rules {
    destination = var.svc_gw_storage
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

##################################################
# MGMT Route Table
##################################################

resource "oci_core_route_table" "mgmt_rt" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "mgmt_rt"

  route_rules {
    destination = var.default_route
    network_entity_id = oci_core_internet_gateway.igw.id
  }

  route_rules {
    destination = var.svc_gw_storage
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

##################################################
# App Route Table
##################################################

resource "oci_core_route_table" "app_rt" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "app_rt"

  route_rules {
    destination = var.default_route
    network_entity_id = oci_core_nat_gateway.ngw.id
  }

  route_rules {
    destination = var.svc_gw_all
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

##################################################
# DB Route Table
##################################################

resource "oci_core_route_table" "db_rt" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "${var.vcn_dns_label}_db_rt"

  route_rules {
    destination = var.default_route
    network_entity_id = oci_core_nat_gateway.ngw.id
  }

  route_rules {
    destination = var.svc_gw_all
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}
