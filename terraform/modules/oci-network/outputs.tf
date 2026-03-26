// Return created network resources so parent stacks can compose on top.
output "vcn_id" {
  description = "Created VCN OCID."
  value       = oci_core_vcn.this.id
}

output "vcn_cidr_blocks" {
  description = "CIDR blocks assigned to the VCN."
  value       = oci_core_vcn.this.cidr_blocks
}

output "internet_gateway_id" {
  description = "Created internet gateway OCID."
  value       = oci_core_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "Created NAT gateway OCID."
  value       = oci_core_nat_gateway.this.id
}

output "service_gateway_id" {
  description = "Created service gateway OCID."
  value       = oci_core_service_gateway.this.id
}

output "public_subnet_id" {
  description = "Created public subnet OCID."
  value       = oci_core_subnet.this["public"].id
}

output "app_staging_subnet_id" {
  description = "Created private staging application subnet OCID."
  value       = oci_core_subnet.this["app_staging"].id
}

output "app_prod_subnet_id" {
  description = "Created private production application subnet OCID."
  value       = oci_core_subnet.this["app_prod"].id
}
