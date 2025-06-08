##################################################
# MGMT Instances
##################################################

resource "oci_core_instance" "mgmt001" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD3 -1]["name"]
  compartment_id = oci_identity_compartment.playground-compartment.id
  display_name = var.mgmt001
  shape = var.instance_shape

  create_vnic_details {
    subnet_id = oci_core_subnet.mgmt_subnet.id
    private_ip = cidrhost(oci_core_subnet.mgmt_subnet.cidr_block, 10)
    display_name = var.mgmt001
    nsg_ids = [oci_core_network_security_group.mgmt_nsg.id]
  }

  source_details {
    source_type = "image"
    source_id = lookup(data.oci_core_images.images.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  provisioner "file" {
    content = tls_private_key.mgmt001_key.public_key_openssh
    destination = ".ssh/id_rsa.pub"
    connection {
      type = "ssh"
      user = var.user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "file" {
    content = tls_private_key.mgmt001_key.private_key_pem
    destination = ".ssh/id_rsa"
    connection {
      type = "ssh"
      user = var.user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "file" {
    content = file("~/code/python/OCI_Portfolio/app-provisioner.sh")
    destination = "/home/${var.user}/app-provisioner.sh"
    connection {
      type = "ssh"
      user = var.user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "file" {
    content = file("~/code/python/OCI_Portfolio/mgmt-provisioner.sh")
    destination = "/home/${var.user}/mgmt-provisioner.sh"
    connection {
      type = "ssh"
      user = var.user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/${var.user}/.ssh/id_rsa"
    ]
    connection {
      type = "ssh"
      user = var.user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
  }

  metadata = {
    ssh_authorized_keys = format("%s%s", file(var.ssh_public_key), var.ssh_public_key_cloud-shell)
  } 

  shape_config {
    memory_in_gbs = 1
    ocpus = 1
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /home/${var.user}/mgmt-provisioner.sh ${var.user} ${var.user} ${var.app001} ${oci_core_instance.app001.private_ip} ${var.app002} ${oci_core_instance.app002.private_ip}",
      "ssh -o StrictHostKeyChecking=accept-new ${var.user}@${oci_core_instance.app001.private_ip} 'bash -s' < /home/${var.user}/app-provisioner.sh",
      "ssh -o StrictHostKeyChecking=accept-new ${var.user}@${oci_core_instance.app002.private_ip} 'bash -s' < /home/${var.user}/app-provisioner.sh",
    ]
    connection {
      type = "ssh"
      user = var.user
      host = self.public_ip
      private_key = file(var.ssh_private_key)
    }
  } 
}

##################################################
# App Instances
##################################################

resource "oci_core_instance" "app001" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD1 -1]["name"]
  compartment_id = oci_identity_compartment.playground-compartment.id
  display_name = var.app001
  shape = var.instance_shape

  create_vnic_details {
    subnet_id = oci_core_subnet.app_subnet.id
    private_ip = cidrhost(oci_core_subnet.app_subnet.cidr_block, 10)
    display_name = var.app001
    assign_public_ip = false
    nsg_ids = [oci_core_network_security_group.app_nsg.id]
  }

  source_details {
    source_type = "image"
    source_id = lookup(data.oci_core_images.images.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = format("%s%s", tls_private_key.mgmt001_key.public_key_openssh, var.ssh_public_key_cloud-shell)
  }

  shape_config {
    memory_in_gbs = 1
    ocpus = 1
  }

}

resource "oci_core_instance" "app002" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD2 -1]["name"]
  compartment_id = oci_identity_compartment.playground-compartment.id
  display_name = var.app002
  shape = var.instance_shape

  create_vnic_details {
    subnet_id = oci_core_subnet.app_subnet.id
    private_ip = cidrhost(oci_core_subnet.app_subnet.cidr_block, 11)
    display_name = var.app002
    assign_public_ip = false
    nsg_ids = [oci_core_network_security_group.app_nsg.id]
  }

  source_details {
    source_type = "image"
    source_id = lookup(data.oci_core_images.images.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = format("%s%s", tls_private_key.mgmt001_key.public_key_openssh, var.ssh_public_key_cloud-shell)
  }

  shape_config {
    memory_in_gbs = 1
    ocpus = 1
  }

}
