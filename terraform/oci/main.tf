locals {
  parent_compartment_name = var.project_name

  environment_compartment_names = {
    for env_name, config in var.environment_compartments :
    env_name => {
      name        = "${local.parent_compartment_name}-${env_name}"
      description = config.description
    }
  }
}

module "project_compartment" {
  source = "../modules/compartment"

  parent_compartment_id = var.tenancy_ocid
  name                  = local.parent_compartment_name
  description           = var.project_compartment_description
}

module "environment_compartments" {
  for_each = local.environment_compartment_names
  source   = "../modules/compartment"

  parent_compartment_id = module.project_compartment.id
  name                  = each.value.name
  description           = each.value.description
}
