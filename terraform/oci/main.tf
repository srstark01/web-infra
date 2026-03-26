// This stack is responsible for creating one environment compartment,
// such as "web-infra-dev" or "web-infra-prod".
locals {
  // Use an explicitly supplied parent OCID when provided.
  // Otherwise, look it up from the shared stack's Terraform state.
  resolved_parent_compartment_id = (
    var.parent_compartment_id != null 
    ? var.parent_compartment_id : 
    data.terraform_remote_state.shared[0].outputs.project_compartment_id
    )

  // Environment compartments follow the pattern "<project>-<environment>".
  environment_compartment_name   = "${var.project_name}-${var.environment_name}"
}

// When parent_compartment_id is not passed directly, read the shared
// stack's local state file to discover the project compartment OCID.
data "terraform_remote_state" "shared" {
  count   = var.parent_compartment_id == null ? 1 : 0
  backend = "local"

  config = {
    // This path points at the state file created by terraform/oci-shared.
    path = var.shared_state_path
  }
}

// Reuse the shared module that knows how to create a single OCI compartment.
module "environment_compartment" {
  source = "../modules/compartment"

  parent_compartment_id = local.resolved_parent_compartment_id
  name                  = local.environment_compartment_name
  description           = var.environment_description
}
