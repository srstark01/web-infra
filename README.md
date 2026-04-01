# web-infra

Terraform-based OCI infrastructure for the `web-infra` project, built around reusable modules and a per-environment stack.

This repository currently provisions:

- a shared parent OCI compartment
- an environment-specific child compartment such as `web-infra-dev`
- a VCN with public, staging-app, and prod-app subnets
- a public management instance `mgmt-001`
- a private staging instance `stg-001`
- a public staging load balancer with:
  - HTTP `80` to HTTPS `443` redirect
  - `stage.abidex.org` routed to `stg-001:443`
  - `stage.shawnstark.net` routed to `stg-001:8443`

Certificate lifecycle is intentionally not managed in Terraform. Terraform only references the OCI load balancer certificate bundle name. Certificate issuance and upload are orchestrated from the control node via Ansible in the sibling repository at `/home/srstark01/dev/web-config`.

**Repository Layout**

- `terraform/common.tfvars`
  Shared Terraform values used by multiple stacks.
- `terraform/oci-shared`
  Creates the parent `web-infra` compartment.
- `terraform/oci`
  Creates one environment stack, including network, instances, and the staging load balancer.
- `terraform/oci/env`
  Environment-specific `.tfvars` such as `dev.tfvars` and `prod.tfvars`.
- `terraform/modules/compartment`
  Reusable OCI compartment module.
- `terraform/modules/network`
  Reusable VCN, subnet, route table, gateway, and security-list module.
- `terraform/modules/instance`
  Reusable compute instance module.
- `terraform/modules/nsg`
  Reusable network security group module.
- `terraform/modules/load-balancer`
  Reusable OCI load balancer module.

**Current OCI Design**

- `mgmt-001`
  - lives in the public subnet
  - has a fixed private IP based on `management_instance_001_private_ip_last_octet`
  - has a public IP
  - allows SSH and RDP from `local_public_IP`
- `stg-001`
  - lives in the private staging subnet
  - has a fixed private IP based on `staging_instance_001_private_ip_last_octet`
  - has no public IP
  - receives traffic from the public subnet on `443` and `8443`
- staging load balancer
  - lives in the public subnet
  - serves HTTP on `80` and redirects to HTTPS
  - serves HTTPS on `443`
  - uses hostname routing:
    - `stage.abidex.org` -> backend set on `stg-001:443`
    - `stage.shawnstark.net` -> backend set on `stg-001:8443`
  - health checks both backends on `/home`
  - expects an existing OCI LB certificate bundle named by `load_balancer_certificate_name`

**Important Certificates Note**

Terraform does not create the load balancer certificate bundle. The LB listeners are configured to use an existing OCI LB certificate bundle name, which defaults to:

```hcl
load_balancer_certificate_name = "staging_live_cert"
```

That means the certificate bundle must already exist on the OCI load balancer before the HTTPS listeners can be applied successfully.

The intended workflow is:

1. issue/renew the real certificate on `mgmt-001`
2. fetch the PEM files back to the control node
3. upload the bundle to the OCI load balancer using OCI CLI
4. run `terraform apply` if the listeners still need to be aligned to that bundle name

**Prerequisites**

- Terraform `>= 1.5.0`
- OCI CLI configured on the control node
- OCI API credentials in `terraform/common.tfvars` and `terraform/oci/terraform.tfvars`
- access to the sibling Ansible repo at:
  - `/home/srstark01/dev/web-config`
- Dynu DNS API credentials available on the control node when running the certificate workflow:
  - `DYNU_CLIENT_ID`
  - `DYNU_SECRET`

**Shared Bootstrap**

Create the shared parent compartment once:

```bash
terraform -chdir=terraform/oci-shared init
terraform -chdir=terraform/oci-shared apply \
  -var-file=../common.tfvars \
  -var-file=terraform.tfvars
```

This stack creates the parent compartment that environment stacks nest under.

**Environment Configuration**

Before applying `terraform/oci`, review:

- `terraform/oci/terraform.tfvars`
- `terraform/oci/env/dev.tfvars`
- `terraform/oci/env/prod.tfvars`

At minimum, set:

- `management_ssh_authorized_keys_path`
- `local_public_IP`
- `management_instance_001_private_ip_last_octet`
- `staging_instance_001_private_ip_last_octet`
- any desired LB hostnames or cert bundle name overrides

Examples with the current defaults:

- `mgmt-001` in `dev` -> `10.40.0.10`
- `stg-001` in `dev` -> `10.40.10.10`
- `mgmt-001` in `prod` -> `10.50.0.10`
- `stg-001` in `prod` -> `10.50.10.10`

**Environment Deploys**

Each environment should use its own Terraform workspace.

Development example:

```bash
terraform -chdir=terraform/oci init
terraform -chdir=terraform/oci workspace new dev
terraform -chdir=terraform/oci workspace select dev
terraform -chdir=terraform/oci apply \
  -var-file=../common.tfvars \
  -var-file=terraform.tfvars \
  -var-file=env/dev.tfvars
```

Production example:

```bash
terraform -chdir=terraform/oci workspace new prod
terraform -chdir=terraform/oci workspace select prod
terraform -chdir=terraform/oci apply \
  -var-file=../common.tfvars \
  -var-file=terraform.tfvars \
  -var-file=env/prod.tfvars
```

**Recommended Deployment Order**

For a new environment:

1. apply `terraform/oci-shared` if the parent compartment does not exist yet
2. apply `terraform/oci` to build the environment compartment, network, instances, and LB structure
3. issue and upload the real staging certificate from the control node using Ansible
4. point public DNS at the load balancer public IP

If the HTTPS listener apply depends on the cert bundle already existing, run the Ansible cert workflow before the final `terraform apply`.

**Useful Terraform Outputs**

The environment stack exposes outputs for:

- VCN and subnet OCIDs
- `mgmt-001` ID, public IP, private IP, and NSG
- `stg-001` ID, private IP, public IP, and NSG
- staging LB ID, public IPs, and NSG

To inspect them:

```bash
terraform -chdir=terraform/oci output
```

Examples:

```bash
terraform -chdir=terraform/oci output management_instance_001_public_ip
terraform -chdir=terraform/oci output staging_instance_001_private_ip
terraform -chdir=terraform/oci output load_balancer_public_ips
```

**SSH Access Model**

- direct SSH from your workstation to `mgmt-001` uses its public IP
- `stg-001` is private-only
- access to `stg-001` should go through `mgmt-001`, for example with `ProxyJump`

Example:

```bash
ssh -J opc@<mgmt-001-public-ip> opc@<stg-001-private-ip>
```

**Load Balancer Module**

The reusable load balancer module in `terraform/modules/load-balancer` is responsible for:

- OCI load balancer creation
- backend sets and backends
- hostnames
- HTTP redirect rule set
- HTTP and HTTPS listeners

It does not create certificate bundles. It assumes the named bundle already exists on the load balancer.

**Certificate Workflow**

Certificate automation lives in the sibling Ansible repo:

- playbook:
  - `/home/srstark01/dev/web-config/ansible/playbooks/staging_lb_cert.yml`
- role defaults:
  - `/home/srstark01/dev/web-config/ansible/roles/lb_cert/defaults/main.yml`
- issue/fetch tasks:
  - `/home/srstark01/dev/web-config/ansible/roles/lb_cert/tasks/issue.yml`
- OCI upload tasks:
  - `/home/srstark01/dev/web-config/ansible/roles/lb_cert/tasks/upload.yml`

The intended control-node flow is:

1. Ansible connects to `mgmt-001`
2. `acme.sh` issues a SAN cert for:
   - `stage.abidex.org`
   - `stage.shawnstark.net`
3. Ansible fetches:
   - `fullchain.pem`
   - `privkey.pem`
   back to the control node
4. The control node uploads that bundle to the OCI load balancer as `staging_live_cert`

Run it from the control node:

```bash
cd /home/srstark01/dev/web-config/ansible
export DYNU_CLIENT_ID=...
export DYNU_SECRET=...
ansible-playbook playbooks/staging_lb_cert.yml
```

If your OCI CLI uses a non-default profile or config file:

```bash
export OCI_CLI_PROFILE=DEFAULT
export OCI_CLI_CONFIG_FILE=~/.oci/config
```

If you want the playbook to run `terraform apply` after upload:

```bash
ansible-playbook playbooks/staging_lb_cert.yml -e lb_cert_apply_terraform=true
```

**Operational Notes**

- Do not commit real certificate material into this repository.
- The current certificate bundle name is just a reference string from Terraform to OCI LB.
- Renewals should be driven from the control node through Ansible, not by putting PEM contents into Terraform.
- OCI load balancer rule sets may round-trip computed fields differently than Terraform expects; the load balancer module already ignores those unstable redirect-rule item diffs.

**Validation**

Typical validation commands:

```bash
terraform -chdir=terraform/oci fmt
terraform -chdir=terraform/oci validate
```

To validate the Ansible certificate playbook:

```bash
cd /home/srstark01/dev/web-config/ansible
ANSIBLE_LOCAL_TEMP=/tmp ANSIBLE_REMOTE_TEMP=/tmp/.ansible/tmp \
ansible-playbook playbooks/staging_lb_cert.yml --syntax-check
```

**Known Repository Boundary**

This repository owns infrastructure structure.

The sibling repository `/home/srstark01/dev/web-config` owns host configuration and the certificate automation flow used to populate the OCI load balancer certificate bundle.
