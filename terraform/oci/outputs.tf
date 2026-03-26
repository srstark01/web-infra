output "project_compartment_id" {
  description = "OCID of the parent project compartment."
  value       = module.project_compartment.id
}

output "project_compartment_name" {
  description = "Name of the parent project compartment."
  value       = module.project_compartment.name
}

output "environment_compartment_ids" {
  description = "Environment compartment OCIDs keyed by environment name."
  value = {
    for env, module_instance in module.environment_compartments :
    env => module_instance.id
  }
}

output "environment_compartment_names" {
  description = "Environment compartment names keyed by environment name."
  value = {
    for env, module_instance in module.environment_compartments :
    env => module_instance.name
  }
}
