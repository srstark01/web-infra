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
  environment_compartment_name     = "${var.project_name}-${var.environment_name}"
  network_name_prefix              = "${local.environment_compartment_name}-network"
  vcn_dns_label                    = substr(var.environment_name, 0, 15)
  management_instance_001_name     = "${local.environment_compartment_name}-mgmt-001"
  management_instance_001_nsg_name = "${local.environment_compartment_name}-mgmt-001-nsg"
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

data "oci_identity_availability_domains" "environment" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "management" {
  compartment_id           = var.tenancy_ocid
  operating_system         = var.management_os
  operating_system_version = var.management_os_version
  shape                    = var.management_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

module "environment_network" {
  source = "../modules/network"

  compartment_id                = module.environment_compartment.id
  name_prefix                   = local.network_name_prefix
  vcn_dns_label                 = local.vcn_dns_label
  vcn_cidr_block                = var.vcn_cidr_block
  public_subnet_cidr_block      = var.public_subnet_cidr_block
  app_staging_subnet_cidr_block = var.app_staging_subnet_cidr_block
  app_prod_subnet_cidr_block    = var.app_prod_subnet_cidr_block
}

module "management_instance_001_nsg" {
  source = "../modules/nsg"

  compartment_id = module.environment_compartment.id
  vcn_id         = module.environment_network.vcn_id
  display_name   = local.management_instance_001_nsg_name
  rules = [
    {
      description    = "Allow SSH only from the trusted public IP."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = var.management_instance_001_ssh_allowed_cidr
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 22, max = 22 }
    },
    {
      description = "Allow all outbound traffic from the management instance."
      direction   = "EGRESS"
      protocol    = "all"
      cidr        = "0.0.0.0/0"
      cidr_type   = "CIDR_BLOCK"
    }
  ]
}

module "management_instance" {
  source = "../modules/instance"

  availability_domain = coalesce(
    var.management_availability_domain,
    data.oci_identity_availability_domains.environment.availability_domains[0].name,
  )
  compartment_id = module.environment_compartment.id
  display_name   = local.management_instance_001_name
  shape          = var.management_shape
  shape_config = can(regex("Flex$", var.management_shape)) ? {
    ocpus         = var.management_shape_ocpus
    memory_in_gbs = var.management_shape_memory_in_gbs
  } : null
  subnet_id               = module.environment_network.public_subnet_id
  assign_public_ip        = true
  hostname_label          = "mgmt-001"
  nsg_ids                 = [module.management_instance_001_nsg.id]
  ssh_authorized_keys     = trimspace(file(pathexpand(var.management_ssh_authorized_keys_path)))
  image_id                = data.oci_core_images.management.images[0].id
  boot_volume_size_in_gbs = var.management_boot_volume_size_in_gbs
}
