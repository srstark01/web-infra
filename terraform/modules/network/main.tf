// Reusable OCI network building block for one environment VCN.
data "oci_core_services" "all" {}

locals {
  subnets = {
    public = {
      cidr_block                 = var.public_subnet_cidr_block
      dns_label                  = "public"
      display_name_suffix        = "public"
      prohibit_public_ip_on_vnic = false
      route_table_key            = "public"
    }
    app_staging = {
      cidr_block                 = var.app_staging_subnet_cidr_block
      dns_label                  = "stagingapp"
      display_name_suffix        = "app-staging"
      prohibit_public_ip_on_vnic = true
      route_table_key            = "private"
    }
    app_prod = {
      cidr_block                 = var.app_prod_subnet_cidr_block
      dns_label                  = "prodapp"
      display_name_suffix        = "app-prod"
      prohibit_public_ip_on_vnic = true
      route_table_key            = "private"
    }
  }
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.vcn_cidr_block]
  display_name   = "${var.name_prefix}-vcn"
  dns_label      = var.vcn_dns_label
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-igw"
  enabled        = true
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-nat"
  block_traffic  = false
}

resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-sgw"

  services {
    service_id = data.oci_core_services.all.services[0].id
  }
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-public-rt"

  route_rules {
    description       = "Public internet access via internet gateway."
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-private-rt"

  route_rules {
    description       = "Outbound internet access via NAT gateway."
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }

  route_rules {
    description       = "Private Oracle Services Network access via service gateway."
    destination       = data.oci_core_services.all.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-public-sl"

  egress_security_rules {
    description      = "Allow all outbound traffic from the public subnet."
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-private-sl"

  egress_security_rules {
    description      = "Allow all outbound traffic from the private subnets."
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }
}

resource "oci_core_subnet" "this" {
  for_each = local.subnets

  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = each.value.cidr_block
  display_name               = "${var.name_prefix}-${each.value.display_name_suffix}"
  dns_label                  = each.value.dns_label
  route_table_id             = each.value.route_table_key == "public" ? oci_core_route_table.public.id : oci_core_route_table.private.id
  security_list_ids          = each.value.route_table_key == "public" ? [oci_core_security_list.public.id] : [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
}
