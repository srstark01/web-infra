# web-infra

OCI infrastructure rebuilt around reusable Terraform modules.

## Structure

- `terraform/modules/compartment`: reusable compartment module
- `terraform/modules/network`: reusable VCN, subnet, and gateway module
- `terraform/modules/instance`: reusable compute instance module
- `terraform/oci-shared`: shared stack for the parent OCI compartment
- `terraform/oci`: environment stack for a single child compartment
- `terraform/oci/env`: environment-specific variable files

## Shared Bootstrap

Create the shared parent compartment once:

```bash
terraform -chdir=terraform/oci-shared init
terraform -chdir=terraform/oci-shared apply -var-file=../common.tfvars -var-file=terraform.tfvars
```

This stack creates:

- parent compartment: `web-infra`

## Environment Deploys

Each environment is deployed from `terraform/oci` and should use its own
Terraform workspace so state stays isolated.

Examples:

```bash
terraform -chdir=terraform/oci init
terraform -chdir=terraform/oci workspace new dev
terraform -chdir=terraform/oci workspace select dev
terraform -chdir=terraform/oci apply -var-file=../common.tfvars -var-file=terraform.tfvars -var-file=env/dev.tfvars
```

```bash
terraform -chdir=terraform/oci workspace new prod
terraform -chdir=terraform/oci workspace select prod
terraform -chdir=terraform/oci apply -var-file=../common.tfvars -var-file=terraform.tfvars -var-file=env/prod.tfvars
```

The environment stack reads the parent compartment ID from the shared stack's
local state by default, so `prod` can be deployed after `dev` without changing
or destroying `dev`.

Before applying the environment stack, update `terraform/oci/terraform.tfvars`
with the management OS selection and the SSH public key path to install on the
management instance.
