resource "oci_core_instance" "mgmt001" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2]["name"]
  compartment_id = oci_identity_compartment.compartment.id
  display_name = var.mgmt_hostname_mgmt-001
  shape = var.mgmt_shape

  create_vnic_details {
    subnet_id = oci_core_subnet.mgmt_subnet.id
    private_ip = cidrhost(oci_core_subnet.mgmt_subnet.cidr_block, 10)
    assign_public_ip = true
    display_name = var.mgmt_hostname_mgmt-001
    nsg_ids = [oci_core_network_security_group.mgmt_nsg.id]
  }

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.mgmt_images.images[0].id
    boot_volume_size_in_gbs = "100"
  }

  shape_config {
    memory_in_gbs = 4
    ocpus = 2
  }

  provisioner "file" {
    content = tls_private_key.mgmt001_key.public_key_openssh
    destination = ".ssh/id_rsa.pub"
    connection {
      type = "ssh"
      user = var.mgmt_user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "file" {
    content = tls_private_key.mgmt001_key.private_key_pem
    destination = ".ssh/id_rsa"
    connection {
      type = "ssh"
      user = var.mgmt_user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/${var.mgmt_user}/.ssh/id_rsa"
    ]
    connection {
      type = "ssh"
      user = var.mgmt_user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
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