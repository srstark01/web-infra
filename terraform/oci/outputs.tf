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

output "mgmt_instances_nsg_id" {
  description = "OCID of the NSG attached to the management instance."
  value       = module.mgmt_instances_nsg.id
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

output "stg_instances_nsg_id" {
  description = "OCID of the NSG attached to the staging instance."
  value       = module.stg_instances_nsg.id
}

output "app_instance_001_id" {
  description = "OCID of app-001."
  value       = module.app_instance_001.id
}

output "app_instance_001_private_ip" {
  description = "Primary private IP address of app-001."
  value       = module.app_instance_001.private_ip
}

output "app_instance_001_public_ip" {
  description = "Primary public IP address of app-001, if assigned."
  value       = module.app_instance_001.public_ip
}

output "app_instance_001_nsg_id" {
  description = "OCID of the NSG attached to app-001."
  value       = module.app_instances_nsg.id
}

output "app_instance_002_id" {
  description = "OCID of app-002."
  value       = module.app_instance_002.id
}

output "app_instance_002_private_ip" {
  description = "Primary private IP address of app-002."
  value       = module.app_instance_002.private_ip
}

output "app_instance_002_public_ip" {
  description = "Primary public IP address of app-002, if assigned."
  value       = module.app_instance_002.public_ip
}

output "app_instance_002_nsg_id" {
  description = "OCID of the NSG attached to app-002."
  value       = module.app_instances_nsg.id
}

output "autonomous_database_id" {
  description = "OCID of the Autonomous Database."
  value       = module.autonomous_database.id
}

output "vault_id" {
  description = "OCID of the environment vault."
  value       = module.environment_vault.vault_id
}

output "vault_key_id" {
  description = "OCID of the environment vault master key."
  value       = module.environment_vault.key_id
}

output "vault_secret_ids" {
  description = "Vault secret OCIDs keyed by secret name."
  value       = module.environment_vault.secret_ids
}

output "autonomous_database_display_name" {
  description = "Display name of the Autonomous Database."
  value       = module.autonomous_database.display_name
}

output "autonomous_database_db_name" {
  description = "Database name of the Autonomous Database."
  value       = module.autonomous_database.db_name
}

output "autonomous_database_whitelisted_ips" {
  description = "Public IP allowlist applied to the Autonomous Database."
  value       = module.autonomous_database.whitelisted_ips
}

output "load_balancer_id" {
  description = "OCID of the staging load balancer."
  value       = module.load_balancer.id
}

output "load_balancer_public_ips" {
  description = "Public IP addresses assigned to the staging load balancer."
  value       = module.load_balancer.public_ips
}

output "load_balancer_nsg_id" {
  description = "OCID of the NSG attached to the staging load balancer."
  value       = module.load_balancer_nsg.id
}
