# resource "oci_core_instance" "instance" {
#   for_each = tomap({
#     for pair in flatten([
#       for env, cfg in var.envs : [
#         for node in ((contains(keys(cfg), "nodes") && cfg.nodes != null) ? cfg.nodes : []) : {
#           key = "${env}:${node.name}"
#           value = {
#             key = env,
#             ad = node.ad,
#             name = node.name,
#             node_shape = cfg.node_shape,
#             ip = node.ip,
#             public = node.public,
#             disk_size = cfg.disk_size,
#             mem = cfg.mem
#             cpu = cfg.cpu
#             user = cfg.user
#           }
#         }
#       ]
#     ]) : pair.key => pair.value
#   })

#   availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.ad]["name"]
#   compartment_id = oci_identity_compartment.compartment.id
#   display_name = "${var.compartment_name}_instance_${each.value.name}_${each.value.key}"
#   shape = each.value.node_shape

#   create_vnic_details {
#     subnet_id = oci_core_subnet.subnet[each.value.key].id
#     private_ip = cidrhost(oci_core_subnet.subnet[each.value.key].cidr_block, each.value.ip)
#     assign_public_ip = each.value.public
#     display_name = "${var.compartment_name}_vnic_${each.value.name}"
#     nsg_ids = [oci_core_network_security_group.nsg[each.value.key].id]
#   }

#   source_details {
#     source_type = "image"
#     source_id = data.oci_core_images.images[each.value.key].images[0].id
#     boot_volume_size_in_gbs = each.value.disk_size
#   }

#   shape_config {
#     memory_in_gbs = each.value.mem
#     ocpus = each.value.cpu
#   }

#   metadata = {
#     ssh_authorized_keys = format("%s%s", file(var.ssh_public_key), var.ssh_public_key_cloud-shell)
#   }

#   agent_config {
#     are_all_plugins_disabled = false

#     plugins_config {
#       name   = "Bastion"
#       desired_state = "ENABLED"
#     }
#   }
# }

resource "oci_core_instance" "instance_mgmt" {
  for_each = tomap({
    for node in (
      contains(keys(var.envs.mgmt), "nodes") && var.envs.mgmt.nodes != null
    ) ? var.envs.mgmt.nodes : [] : node.name => {
      key        = "mgmt"
      ad         = node.ad
      name       = node.name
      node_shape = var.envs.mgmt.node_shape
      ip         = node.ip
      public     = node.public
      disk_size  = var.envs.mgmt.disk_size
      mem        = var.envs.mgmt.mem
      cpu        = var.envs.mgmt.cpu
      user       = var.envs.mgmt.user
    }
  })

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.ad]["name"]
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "${var.compartment_name}_instance_${each.value.name}_${each.value.key}"
  shape               = each.value.node_shape

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet[each.value.key].id
    private_ip     = cidrhost(oci_core_subnet.subnet[each.value.key].cidr_block, each.value.ip)
    assign_public_ip = each.value.public
    display_name   = "${var.compartment_name}_vnic_${each.value.name}"
    nsg_ids        = [oci_core_network_security_group.nsg[each.value.key].id]
  }

  source_details {
    source_type            = "image"
    source_id              = data.oci_core_images.images[each.value.key].images[0].id
    boot_volume_size_in_gbs = each.value.disk_size
  }

  shape_config {
    memory_in_gbs = each.value.mem
    ocpus         = each.value.cpu
  }

  metadata = {
    ssh_authorized_keys = format("%s%s", file(var.ssh_public_key), var.ssh_public_key_cloud-shell)
  }

  agent_config {
    are_all_plugins_disabled = false

    plugins_config {
      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }
}

resource "oci_core_instance" "instance_stg" {
  for_each = tomap({
    for node in (
      contains(keys(var.envs.stg), "nodes") && var.envs.stg.nodes != null
    ) ? var.envs.stg.nodes : [] : node.name => {
      key        = "stg"
      ad         = node.ad
      name       = node.name
      node_shape = var.envs.stg.node_shape
      ip         = node.ip
      public     = node.public
      disk_size  = var.envs.stg.disk_size
      mem        = var.envs.stg.mem
      cpu        = var.envs.stg.cpu
      user       = var.envs.stg.user
    }
  })

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.ad]["name"]
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "${var.compartment_name}_instance_${each.value.name}_${each.value.key}"
  shape               = each.value.node_shape

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet[each.value.key].id
    private_ip     = cidrhost(oci_core_subnet.subnet[each.value.key].cidr_block, each.value.ip)
    assign_public_ip = each.value.public
    display_name   = "${var.compartment_name}_vnic_${each.value.name}"
    nsg_ids        = [oci_core_network_security_group.nsg[each.value.key].id]
  }

  source_details {
    source_type            = "image"
    source_id              = data.oci_core_images.images[each.value.key].images[0].id
    boot_volume_size_in_gbs = each.value.disk_size
  }

  shape_config {
    memory_in_gbs = each.value.mem
    ocpus         = each.value.cpu
  }

  metadata = {
    ssh_authorized_keys = format("%s%s", file(var.ssh_public_key), var.ssh_public_key_cloud-shell)
  }

  agent_config {
    are_all_plugins_disabled = false

    plugins_config {
      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }
}

resource "oci_core_instance" "instance_app" {
  for_each = tomap({
    for node in (
      contains(keys(var.envs.app), "nodes") && var.envs.app.nodes != null
    ) ? var.envs.app.nodes : [] : node.name => {
      key        = "app"
      ad         = node.ad
      name       = node.name
      node_shape = var.envs.app.node_shape
      ip         = node.ip
      public     = node.public
      disk_size  = var.envs.app.disk_size
      mem        = var.envs.app.mem
      cpu        = var.envs.app.cpu
      user       = var.envs.app.user
    }
  })

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.ad]["name"]
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "${var.compartment_name}_instance_${each.value.name}_${each.value.key}"
  shape               = each.value.node_shape

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet[each.value.key].id
    private_ip     = cidrhost(oci_core_subnet.subnet[each.value.key].cidr_block, each.value.ip)
    assign_public_ip = each.value.public
    display_name   = "${var.compartment_name}_vnic_${each.value.name}"
    nsg_ids        = [oci_core_network_security_group.nsg[each.value.key].id]
  }

  source_details {
    source_type            = "image"
    source_id              = data.oci_core_images.images[each.value.key].images[0].id
    boot_volume_size_in_gbs = each.value.disk_size
  }

  shape_config {
    memory_in_gbs = each.value.mem
    ocpus         = each.value.cpu
  }

  metadata = {
    ssh_authorized_keys = format("%s%s", file(var.ssh_public_key), var.ssh_public_key_cloud-shell)
  }

  agent_config {
    are_all_plugins_disabled = false

    plugins_config {
      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }
}

resource "oci_core_instance" "instance_db" {
  for_each = tomap({
    for node in (
      contains(keys(var.envs.db), "nodes") && var.envs.db.nodes != null
    ) ? var.envs.db.nodes : [] : node.name => {
      key        = "db"
      ad         = node.ad
      name       = node.name
      node_shape = var.envs.db.node_shape
      ip         = node.ip
      public     = node.public
      disk_size  = var.envs.db.disk_size
      mem        = var.envs.db.mem
      cpu        = var.envs.db.cpu
      user       = var.envs.db.user
    }
  })

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.ad]["name"]
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "${var.compartment_name}_instance_${each.value.name}_${each.value.key}"
  shape               = each.value.node_shape

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet[each.value.key].id
    private_ip     = cidrhost(oci_core_subnet.subnet[each.value.key].cidr_block, each.value.ip)
    assign_public_ip = each.value.public
    display_name   = "${var.compartment_name}_vnic_${each.value.name}"
    nsg_ids        = [oci_core_network_security_group.nsg[each.value.key].id]
  }

  source_details {
    source_type            = "image"
    source_id              = data.oci_core_images.images[each.value.key].images[0].id
    boot_volume_size_in_gbs = each.value.disk_size
  }

  shape_config {
    memory_in_gbs = each.value.mem
    ocpus         = each.value.cpu
  }

  metadata = {
    ssh_authorized_keys = format("%s%s", file(var.ssh_public_key), var.ssh_public_key_cloud-shell)
  }

  agent_config {
    are_all_plugins_disabled = false

    plugins_config {
      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }
}
