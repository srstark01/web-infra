# web-infra

OCI infrastructure rebuilt around reusable Terraform modules.

## Structure

- `terraform/modules/compartment`: reusable compartment module
- `terraform/oci`: root stack for the shared OCI compartment hierarchy
- `terraform/oci/env`: environment-specific variable files

## Bootstrap Scope

The initial stack creates:

- one parent project compartment under the tenancy
- `dev` and `prod` child compartments under that parent

## Environment Promotion

The same Terraform code is intended to run across environments with different
inputs rather than separate long-lived branches.

Examples:

- `terraform -chdir=terraform/oci plan -var-file=env/dev.tfvars`
- `terraform -chdir=terraform/oci plan -var-file=env/prod.tfvars`

This bootstrap stack creates:

- parent compartment: `web-infra`
- child compartments: `web-infra-dev`, `web-infra-prod`
