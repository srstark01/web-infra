// These outputs are what the environment stack reads via remote state.
output "project_compartment_id" {
  description = "OCID of the parent project compartment."
  value       = module.project_compartment.id
}

// Helpful for confirming the expected shared compartment was created.
output "project_compartment_name" {
  description = "Name of the parent project compartment."
  value       = module.project_compartment.name
}
