// This stack creates the top-level shared project compartment once.
// Environment stacks then create child compartments underneath it.
module "project_compartment" {
  source = "../modules/compartment"

  // The parent of the shared project compartment is the OCI tenancy itself.
  parent_compartment_id = var.tenancy_ocid
  name                  = var.project_name
  description           = var.project_compartment_description
}
