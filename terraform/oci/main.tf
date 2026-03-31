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
  staging_instance_001_name        = "${local.environment_compartment_name}-stg-001"
  staging_instance_001_nsg_name    = "${local.environment_compartment_name}-stg-001-nsg"
  staging_load_balancer_name       = "${local.environment_compartment_name}-stg-lb-001"
  staging_load_balancer_nsg_name   = "${local.environment_compartment_name}-stg-lb-001-nsg"
  staging_http_redirect_rule_set   = "http_to_https"
  staging_primary_backend_set_name = "stage_abidex_org_bs"
  staging_alt_backend_set_name     = "stage_shawnstark_net_bs"
  management_instance_001_private_ip = cidrhost(
    var.public_subnet_cidr_block,
    var.management_instance_001_private_ip_last_octet,
  )
  staging_instance_001_private_ip = cidrhost(
    var.app_staging_subnet_cidr_block,
    var.staging_instance_001_private_ip_last_octet,
  )
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
      cidr           = var.local_public_IP
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 22, max = 22 }
    },
    {
      description    = "Allow RDP only from the trusted public IP."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = var.local_public_IP
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 3389, max = 3389 }
    },
    {
      description    = "Allow HTTPS only from the trusted public IP."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = "0.0.0.0/0"
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow HTTP only from the public internet."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = "0.0.0.0/0"
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 80, max = 80 }
    },
    {
      description = "Allow ICMP only from the trusted public IP."
      direction   = "INGRESS"
      protocol    = "1"
      cidr        = var.local_public_IP
      cidr_type   = "CIDR_BLOCK"
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
  private_ip              = local.management_instance_001_private_ip
  assign_public_ip        = true
  hostname_label          = "mgmt-001"
  nsg_ids                 = [module.management_instance_001_nsg.id]
  ssh_authorized_keys     = trimspace(file(pathexpand(var.management_ssh_authorized_keys_path)))
  image_id                = data.oci_core_images.management.images[0].id
  boot_volume_size_in_gbs = var.management_boot_volume_size_in_gbs
}

module "staging_instance_001_nsg" {
  source = "../modules/nsg"

  compartment_id = module.environment_compartment.id
  vcn_id         = module.environment_network.vcn_id
  display_name   = local.staging_instance_001_nsg_name
  rules = [
    {
      description    = "Allow SSH from mgmt-001."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = "${local.management_instance_001_private_ip}/32"
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 22, max = 22 }
    },
    {
      description    = "Allow HTTPS from the pub subnet."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = var.public_subnet_cidr_block
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow alternate HTTPS from the pub subnet."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = var.public_subnet_cidr_block
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 8443, max = 8443 }
    },
    {
      description = "Allow all outbound traffic from the staging instance."
      direction   = "EGRESS"
      protocol    = "all"
      cidr        = "0.0.0.0/0"
      cidr_type   = "CIDR_BLOCK"
    }
  ]
}

module "staging_instance" {
  source = "../modules/instance"

  availability_domain = coalesce(
    var.management_availability_domain,
    data.oci_identity_availability_domains.environment.availability_domains[0].name,
  )
  compartment_id = module.environment_compartment.id
  display_name   = local.staging_instance_001_name
  shape          = var.management_shape
  shape_config = can(regex("Flex$", var.management_shape)) ? {
    ocpus         = var.management_shape_ocpus
    memory_in_gbs = var.management_shape_memory_in_gbs
  } : null
  subnet_id               = module.environment_network.app_staging_subnet_id
  private_ip              = local.staging_instance_001_private_ip
  assign_public_ip        = false
  hostname_label          = "stg-001"
  nsg_ids                 = [module.staging_instance_001_nsg.id]
  ssh_authorized_keys     = trimspace(file(pathexpand(var.management_ssh_authorized_keys_path)))
  image_id                = data.oci_core_images.management.images[0].id
  boot_volume_size_in_gbs = var.management_boot_volume_size_in_gbs
}

module "staging_load_balancer_nsg" {
  source = "../modules/nsg"

  compartment_id = module.environment_compartment.id
  vcn_id         = module.environment_network.vcn_id
  display_name   = local.staging_load_balancer_nsg_name
  rules = [
    {
      description    = "Allow HTTP from the public internet."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = "0.0.0.0/0"
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 80, max = 80 }
    },
    {
      description    = "Allow HTTPS from the public internet."
      direction      = "INGRESS"
      protocol       = "6"
      cidr           = "0.0.0.0/0"
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow HTTPS to stg-001."
      direction      = "EGRESS"
      protocol       = "6"
      cidr           = "${local.staging_instance_001_private_ip}/32"
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow alternate HTTPS to stg-001."
      direction      = "EGRESS"
      protocol       = "6"
      cidr           = "${local.staging_instance_001_private_ip}/32"
      cidr_type      = "CIDR_BLOCK"
      tcp_port_range = { min = 8443, max = 8443 }
    }
  ]
}

module "staging_load_balancer" {
  source = "../modules/load-balancer"

  compartment_id                  = module.environment_compartment.id
  display_name                    = local.staging_load_balancer_name
  subnet_ids                      = [module.environment_network.public_subnet_id]
  network_security_group_ids      = [module.staging_load_balancer_nsg.id]
  shape                           = var.staging_load_balancer_shape
  minimum_bandwidth_in_mbps       = var.staging_load_balancer_min_bandwidth_mbps
  maximum_bandwidth_in_mbps       = var.staging_load_balancer_max_bandwidth_mbps
  certificate_mode                = var.staging_load_balancer_certificate_mode
  certificate_name                = var.staging_load_balancer_certificate_name
  primary_hostname                = var.stage_abidex_org_hostname
  alternate_hostname              = var.stage_shawnstark_net_hostname
  primary_hostname_name           = "stage_abidex_org"
  alternate_hostname_name         = "stage_shawnstark_net"
  http_redirect_rule_set_name     = local.staging_http_redirect_rule_set
  primary_backend_set_name        = local.staging_primary_backend_set_name
  alternate_backend_set_name      = local.staging_alt_backend_set_name
  backend_ip_address              = module.staging_instance.private_ip
  primary_backend_port            = 443
  alternate_backend_port          = 8443
  health_check_path               = var.staging_load_balancer_health_check_path
  verify_backend_peer_certificate = false
}
