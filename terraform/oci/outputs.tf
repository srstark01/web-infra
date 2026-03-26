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
