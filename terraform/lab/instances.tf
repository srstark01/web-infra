resource "oci_core_instance" "instance" {
  for_each = tomap({
    for pair in flatten([
      for env, cfg in var.envs : [
        for node in ((contains(keys(cfg), "nodes") && cfg.nodes != null) ? cfg.nodes : []) : {
          key = "${env}:${node.name}"
          value = {
            key = env,
            ad = node.ad,
            name = node.name,
            node_shape = cfg.node_shape,
            ip = node.ip,
            public = node.public,
            disk_size = cfg.disk_size,
            mem = cfg.mem
            cpu = cfg.cpu
            user = cfg.user
          }
        }
      ]
    ]) : pair.key => pair.value
  })

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[each.value.ad]["name"]
  compartment_id = oci_identity_compartment.compartment.id
  display_name = "${var.compartment_name}_instance_${each.value.name}_${each.value.key}"
  shape = each.value.node_shape

  create_vnic_details {
    subnet_id = oci_core_subnet.subnet[each.value.key].id
    private_ip = cidrhost(oci_core_subnet.subnet[each.value.key].cidr_block, each.value.ip)
    assign_public_ip = each.value.public
    display_name = "${var.compartment_name}_vnic_${each.value.name}_${each.key}"
    nsg_ids = [oci_core_network_security_group.nsg[each.value.key].id]
  }

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.images[each.value.key].images[0].id
    boot_volume_size_in_gbs = each.value.disk_size
  }

  shape_config {
    memory_in_gbs = each.value.mem
    ocpus = each.value.cpu
  }

  metadata = {
    ssh_authorized_keys = format("%s%s", file(var.ssh_public_key), var.ssh_public_key_cloud-shell)
  }

  agent_config {
    are_all_plugins_disabled = false

    plugins_config {
      name   = "Bastion"
      desired_state = "ENABLED"
    }
  }
}


# resource "null_resource" "mgmt_gen_key"{
#   for_each = {
#     for k, inst in oci_core_instance.instance : k => inst
#     if startswith(k, "mgmt:")   # only mgmt nodes
#   }

#   triggers = {
#     instance_id = oci_core_instance.instance[each.key].id
#   }

#   connection {
#     type        = "ssh"
#     host        = oci_core_instance.instance[each.key].public_ip
#     user        = each.value.user
#     private_key = file(var.ssh_private_key)
#   }

#   provisioner "file" {
#     content     = tls_private_key.key.public_key_openssh
#     destination = "/home/${each.value.user}/.ssh/id_rsa.pub"
#   }

#   provisioner "file" {
#     content     = tls_private_key.key.private_key_pem
#     destination = "/home/${each.value.user}/.ssh/id_rsa"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "set -e",
#       "chown ${each.value.user}:${each.value.user} /home/${each.value.user}/.ssh/id_rsa /home/${each.value.user}/.ssh/id_rsa.pub",
#       "chmod 600 /home/${each.value.user}/.ssh/id_rsa",
#       "chmod 644 /home/${each.value.user}/.ssh/id_rsa.pub"
#     ]
#   }
# }