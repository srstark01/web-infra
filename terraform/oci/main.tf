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
  mgmt_instances_nsg_name          = "${local.environment_compartment_name}-mgmt-001-nsg"
  staging_instance_001_name        = "${local.environment_compartment_name}-stg-001"
  stg_instances_nsg_name           = "${local.environment_compartment_name}-stg-001-nsg"
  app_instance_001_name            = "${local.environment_compartment_name}-app-001"
  app_instances_nsg_name           = "${local.environment_compartment_name}-app-nodes-nsg"
  app_instance_002_name            = "${local.environment_compartment_name}-app-002"
  vault_name                       = "${local.environment_compartment_name}-vault"
  vault_key_name                   = "${local.environment_compartment_name}-vault-key"
  autonomous_database_display_name = "${local.environment_compartment_name}-adb"
  autonomous_database_name = substr(
    lower(replace(replace("${var.project_name}${var.environment_name}adb", "-", ""), "_", "")),
    0,
    14,
  )
  load_balancer_name               = "${local.environment_compartment_name}-stg-lb-001"
  load_balancer_nsg_name           = "${local.environment_compartment_name}-stg-lb-001-nsg"
  staging_http_redirect_rule_set   = "http_to_https"
  staging_primary_backend_set_name = "stage_abidex_org_bs"
  staging_alt_backend_set_name     = "stage_shawnstark_net_bs"
  prod_primary_backend_set_name    = "abidex_org_bs"
  prod_alt_backend_set_name        = "shawnstark_net_bs"
  management_instance_001_private_ip = cidrhost(
    var.public_subnet_cidr_block,
    var.management_instance_001_private_ip_last_octet,
  )
  staging_instance_001_private_ip = cidrhost(
    var.app_staging_subnet_cidr_block,
    var.staging_instance_001_private_ip_last_octet,
  )
  app_instance_001_private_ip = cidrhost(
    var.app_prod_subnet_cidr_block,
    var.app_instance_001_private_ip_last_octet,
  )
  app_instance_002_private_ip = cidrhost(
    var.app_prod_subnet_cidr_block,
    var.app_instance_002_private_ip_last_octet,
  )
  adb_secret_names = {
    adb_admin_password  = "${local.environment_compartment_name}-adb-admin-password"
    adb_mgmt_password   = "${local.environment_compartment_name}-adb-mgmt-password"
    adb_app_password    = "${local.environment_compartment_name}-adb-app-password"
    adb_wallet_password = "${local.environment_compartment_name}-adb-wallet-password"
  }
}

moved {
  from = module.management_instance_001_nsg
  to   = module.mgmt_instances_nsg
}

moved {
  from = module.staging_instance_001_nsg
  to   = module.stg_instances_nsg
}

moved {
  from = module.staging_load_balancer_nsg
  to   = module.load_balancer_nsg
}

moved {
  from = module.staging_load_balancer
  to   = module.load_balancer
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

module "environment_vault" {
  source = "../modules/vault"

  compartment_id               = module.environment_compartment.id
  vault_display_name           = coalesce(var.vault_display_name, local.vault_name)
  vault_type                   = var.vault_type
  key_display_name             = coalesce(var.vault_key_display_name, local.vault_key_name)
  key_algorithm                = var.vault_key_algorithm
  key_length                   = var.vault_key_length
  key_protection_mode          = var.vault_key_protection_mode
  key_is_auto_rotation_enabled = var.vault_key_is_auto_rotation_enabled
  secrets = {
    (local.adb_secret_names.adb_admin_password) = {
      description         = "Admin password for the environment Autonomous Database."
      auto_generate       = true
      passphrase_length   = var.adb_admin_password_length
      generation_template = "DBAAS_DEFAULT_PASSWORD"
    }
    (local.adb_secret_names.adb_mgmt_password) = {
      description         = "Password for the mgmt Autonomous Database user."
      auto_generate       = true
      passphrase_length   = var.adb_wallet_password_length
      generation_template = "DBAAS_DEFAULT_PASSWORD"
    }
    (local.adb_secret_names.adb_app_password) = {
      description         = "Password for the app Autonomous Database user."
      auto_generate       = true
      passphrase_length   = var.adb_wallet_password_length
      generation_template = "DBAAS_DEFAULT_PASSWORD"
    }
    (local.adb_secret_names.adb_wallet_password) = {
      description         = "Shared wallet password for the Autonomous Database client bundle."
      auto_generate       = true
      passphrase_length   = var.adb_wallet_password_length
      generation_template = "DBAAS_DEFAULT_PASSWORD"
    }
  }
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

module "mgmt_instances_nsg" {
  source = "../modules/nsg"

  compartment_id = module.environment_compartment.id
  vcn_id         = module.environment_network.vcn_id
  display_name   = local.mgmt_instances_nsg_name
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
  nsg_ids                 = [module.mgmt_instances_nsg.id]
  ssh_authorized_keys     = trimspace(file(pathexpand(var.management_ssh_authorized_keys_path)))
  image_id                = data.oci_core_images.management.images[0].id
  boot_volume_size_in_gbs = var.management_boot_volume_size_in_gbs
}

module "stg_instances_nsg" {
  source = "../modules/nsg"

  compartment_id = module.environment_compartment.id
  vcn_id         = module.environment_network.vcn_id
  display_name   = local.stg_instances_nsg_name
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
  nsg_ids                 = [module.stg_instances_nsg.id]
  ssh_authorized_keys     = trimspace(file(pathexpand(var.management_ssh_authorized_keys_path)))
  image_id                = data.oci_core_images.management.images[0].id
  boot_volume_size_in_gbs = var.management_boot_volume_size_in_gbs
}

module "app_instances_nsg" {
  source = "../modules/nsg"

  compartment_id = module.environment_compartment.id
  vcn_id         = module.environment_network.vcn_id
  display_name   = local.app_instances_nsg_name
}

module "app_instance_001" {
  source = "../modules/instance"

  availability_domain = coalesce(
    var.management_availability_domain,
    data.oci_identity_availability_domains.environment.availability_domains[0].name,
  )
  compartment_id = module.environment_compartment.id
  display_name   = local.app_instance_001_name
  shape          = var.management_shape
  shape_config = can(regex("Flex$", var.management_shape)) ? {
    ocpus         = var.management_shape_ocpus
    memory_in_gbs = var.management_shape_memory_in_gbs
  } : null
  subnet_id               = module.environment_network.app_prod_subnet_id
  private_ip              = local.app_instance_001_private_ip
  assign_public_ip        = false
  hostname_label          = "app-001"
  nsg_ids                 = [module.app_instances_nsg.id]
  ssh_authorized_keys     = trimspace(file(pathexpand(var.management_ssh_authorized_keys_path)))
  image_id                = data.oci_core_images.management.images[0].id
  boot_volume_size_in_gbs = var.management_boot_volume_size_in_gbs
}

module "app_instance_002" {
  source = "../modules/instance"

  availability_domain = coalesce(
    var.management_availability_domain,
    data.oci_identity_availability_domains.environment.availability_domains[0].name,
  )
  compartment_id = module.environment_compartment.id
  display_name   = local.app_instance_002_name
  shape          = var.management_shape
  shape_config = can(regex("Flex$", var.management_shape)) ? {
    ocpus         = var.management_shape_ocpus
    memory_in_gbs = var.management_shape_memory_in_gbs
  } : null
  subnet_id               = module.environment_network.app_prod_subnet_id
  private_ip              = local.app_instance_002_private_ip
  assign_public_ip        = false
  hostname_label          = "app-002"
  nsg_ids                 = [module.app_instances_nsg.id]
  ssh_authorized_keys     = trimspace(file(pathexpand(var.management_ssh_authorized_keys_path)))
  image_id                = data.oci_core_images.management.images[0].id
  boot_volume_size_in_gbs = var.management_boot_volume_size_in_gbs
}

module "autonomous_database" {
  source = "../modules/autonomous-database"

  compartment_id                       = module.environment_compartment.id
  display_name                         = coalesce(var.adb_display_name, local.autonomous_database_display_name)
  db_name                              = coalesce(var.adb_name, local.autonomous_database_name)
  admin_password_secret_id             = module.environment_vault.secret_ids[local.adb_secret_names.adb_admin_password]
  admin_password_secret_version_number = null
  db_workload                          = var.adb_workload
  db_version                           = var.adb_version
  is_free_tier                         = var.adb_is_free_tier
  license_model                        = var.adb_license_model
  whitelisted_ips = [
    var.local_public_IP,
    "${module.management_instance.public_ip}/32",
  ]
}

module "load_balancer_nsg" {
  source = "../modules/nsg"

  compartment_id = module.environment_compartment.id
  vcn_id         = module.environment_network.vcn_id
  display_name   = local.load_balancer_nsg_name
}

module "mgmt_instances_nsg_rules" {
  source = "../modules/nsg-rules"

  network_security_group_id = module.mgmt_instances_nsg.id
  rules = [
    {
      description    = "Allow SSH only from the trusted public IP."
      direction      = "INGRESS"
      protocol       = "6"
      target         = var.local_public_IP
      target_type    = "CIDR_BLOCK"
      tcp_port_range = { min = 22, max = 22 }
    },
    {
      description    = "Allow RDP only from the trusted public IP."
      direction      = "INGRESS"
      protocol       = "6"
      target         = var.local_public_IP
      target_type    = "CIDR_BLOCK"
      tcp_port_range = { min = 3389, max = 3389 }
    },
    {
      description    = "Allow HTTPS from the public internet."
      direction      = "INGRESS"
      protocol       = "6"
      target         = "0.0.0.0/0"
      target_type    = "CIDR_BLOCK"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow HTTP from the public internet."
      direction      = "INGRESS"
      protocol       = "6"
      target         = "0.0.0.0/0"
      target_type    = "CIDR_BLOCK"
      tcp_port_range = { min = 80, max = 80 }
    },
    {
      description = "Allow ICMP only from the trusted public IP."
      direction   = "INGRESS"
      protocol    = "1"
      target      = var.local_public_IP
      target_type = "CIDR_BLOCK"
    },
    {
      description = "Allow all outbound traffic from the management instance."
      direction   = "EGRESS"
      protocol    = "all"
      target      = "0.0.0.0/0"
      target_type = "CIDR_BLOCK"
    }
  ]
}

module "stg_instances_nsg_rules" {
  source = "../modules/nsg-rules"

  network_security_group_id = module.stg_instances_nsg.id
  rules = [
    {
      description = "Allow all outbound traffic from the staging instance."
      direction   = "EGRESS"
      protocol    = "all"
      target      = "0.0.0.0/0"
      target_type = "CIDR_BLOCK"
    },
    {
      description    = "Allow SSH from the management NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.mgmt_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 22, max = 22 }
    },
    {
      description    = "Allow HTTPS from the management NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.mgmt_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow alternate HTTPS from the management NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.mgmt_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 8443, max = 8443 }
    },
    {
      description    = "Allow HTTPS from the load balancer NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.load_balancer_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow alternate HTTPS from the load balancer NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.load_balancer_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 8443, max = 8443 }
    }
  ]
}

module "app_instances_nsg_rules" {
  source = "../modules/nsg-rules"

  network_security_group_id = module.app_instances_nsg.id
  rules = [
    {
      description = "Allow all outbound traffic from the app nodes."
      direction   = "EGRESS"
      protocol    = "all"
      target      = "0.0.0.0/0"
      target_type = "CIDR_BLOCK"
    },
    {
      description    = "Allow SSH from the management NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.mgmt_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 22, max = 22 }
    },
    {
      description    = "Allow HTTPS from the management NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.mgmt_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow alternate HTTPS from the management NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.mgmt_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 8443, max = 8443 }
    },
    {
      description    = "Allow HTTPS from the load balancer NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.load_balancer_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow alternate HTTPS from the load balancer NSG."
      direction      = "INGRESS"
      protocol       = "6"
      target         = module.load_balancer_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 8443, max = 8443 }
    }
  ]
}

module "load_balancer_nsg_rules" {
  source = "../modules/nsg-rules"

  network_security_group_id = module.load_balancer_nsg.id
  rules = [
    {
      description    = "Allow HTTP from the public internet."
      direction      = "INGRESS"
      protocol       = "6"
      target         = "0.0.0.0/0"
      target_type    = "CIDR_BLOCK"
      tcp_port_range = { min = 80, max = 80 }
    },
    {
      description    = "Allow HTTPS from the public internet."
      direction      = "INGRESS"
      protocol       = "6"
      target         = "0.0.0.0/0"
      target_type    = "CIDR_BLOCK"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow HTTPS to the staging instance NSG."
      direction      = "EGRESS"
      protocol       = "6"
      target         = module.stg_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow alternate HTTPS to the staging instance NSG."
      direction      = "EGRESS"
      protocol       = "6"
      target         = module.stg_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 8443, max = 8443 }
    },
    {
      description    = "Allow HTTPS to the app instances NSG."
      direction      = "EGRESS"
      protocol       = "6"
      target         = module.app_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 443, max = 443 }
    },
    {
      description    = "Allow alternate HTTPS to the app instances NSG."
      direction      = "EGRESS"
      protocol       = "6"
      target         = module.app_instances_nsg.id
      target_type    = "NETWORK_SECURITY_GROUP"
      tcp_port_range = { min = 8443, max = 8443 }
    }
  ]
}

module "load_balancer" {
  source = "../modules/load-balancer"

  compartment_id                = module.environment_compartment.id
  display_name                  = local.load_balancer_name
  subnet_ids                    = [module.environment_network.public_subnet_id]
  network_security_group_ids    = [module.load_balancer_nsg.id]
  shape                         = var.load_balancer_shape
  minimum_bandwidth_in_mbps     = var.load_balancer_min_bandwidth_mbps
  maximum_bandwidth_in_mbps     = var.load_balancer_max_bandwidth_mbps
  certificate_mode              = var.load_balancer_certificate_mode
  certificate_name              = var.load_balancer_certificate_name
  http_redirect_rule_set_name   = local.staging_http_redirect_rule_set
  http_default_backend_set_name = local.staging_primary_backend_set_name
  listeners = [
    {
      name             = "stage_abidex_org"
      hostname         = var.stage_abidex_org_hostname
      backend_set_name = local.staging_primary_backend_set_name
    },
    {
      name             = "stage_shawnstark_net"
      hostname         = var.stage_shawnstark_net_hostname
      backend_set_name = local.staging_alt_backend_set_name
    },
    {
      name             = "abidex_org"
      hostname         = var.abidex_org_hostname
      backend_set_name = local.prod_primary_backend_set_name
    },
    {
      name             = "shawnstark_net"
      hostname         = var.shawnstark_net_hostname
      backend_set_name = local.prod_alt_backend_set_name
    }
  ]
  backend_sets = [
    {
      name        = local.staging_primary_backend_set_name
      port        = 443
      backend_ips = [module.staging_instance.private_ip]
    },
    {
      name        = local.staging_alt_backend_set_name
      port        = 8443
      backend_ips = [module.staging_instance.private_ip]
    },
    {
      name        = local.prod_primary_backend_set_name
      port        = 443
      backend_ips = [module.app_instance_001.private_ip, module.app_instance_002.private_ip]
    },
    {
      name        = local.prod_alt_backend_set_name
      port        = 8443
      backend_ips = [module.app_instance_001.private_ip, module.app_instance_002.private_ip]
    }
  ]
  health_check_path               = var.load_balancer_health_check_path
  verify_backend_peer_certificate = false
}
