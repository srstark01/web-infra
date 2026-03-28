// Expose the resolved parent compartment so callers can see which
// project compartment this environment stack was nested under.
output "parent_compartment_id" {
  description = "OCID of the parent project compartment used for this environment."
  value       = local.resolved_parent_compartment_id
}

// Useful for chaining other Terraform code to the created environment compartment.
output "environment_compartment_id" {
  description = "OCID of the environment compartment."
  value       = module.environment_compartment.id
}

// Human-readable compartment name for verification and debugging.
output "environment_compartment_name" {
  description = "Name of the environment compartment."
  value       = module.environment_compartment.name
}

output "vcn_id" {
  description = "OCID of the environment VCN."
  value       = module.environment_network.vcn_id
}

output "vcn_cidr_blocks" {
  description = "CIDR blocks assigned to the environment VCN."
  value       = module.environment_network.vcn_cidr_blocks
}

output "internet_gateway_id" {
  description = "OCID of the environment internet gateway."
  value       = module.environment_network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "OCID of the environment NAT gateway."
  value       = module.environment_network.nat_gateway_id
}

output "service_gateway_id" {
  description = "OCID of the environment service gateway."
  value       = module.environment_network.service_gateway_id
}

output "public_subnet_id" {
  description = "OCID of the public subnet."
  value       = module.environment_network.public_subnet_id
}

output "app_staging_subnet_id" {
  description = "OCID of the private staging application subnet."
  value       = module.environment_network.app_staging_subnet_id
}

output "app_prod_subnet_id" {
  description = "OCID of the private production application subnet."
  value       = module.environment_network.app_prod_subnet_id
}

output "management_instance_001_id" {
  description = "OCID of the management instance."
  value       = module.management_instance.id
}

output "management_instance_001_private_ip" {
  description = "Primary private IP address of the management instance."
  value       = module.management_instance.private_ip
}

output "management_instance_001_public_ip" {
  description = "Primary public IP address of the management instance."
  value       = module.management_instance.public_ip
}

output "management_instance_001_nsg_id" {
  description = "OCID of the NSG attached to the management instance."
  value       = module.management_instance_001_nsg.id
}

output "staging_instance_001_id" {
  description = "OCID of the staging instance."
  value       = module.staging_instance.id
}

output "staging_instance_001_private_ip" {
  description = "Primary private IP address of the staging instance."
  value       = module.staging_instance.private_ip
}

output "staging_instance_001_public_ip" {
  description = "Primary public IP address of the staging instance, if assigned."
  value       = module.staging_instance.public_ip
}

output "staging_instance_001_nsg_id" {
  description = "OCID of the NSG attached to the staging instance."
  value       = module.staging_instance_001_nsg.id
}
