resource "oci_core_instance" "app001" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0]["name"]
  compartment_id = oci_identity_compartment.compartment.id
  display_name = var.app_hostname_app-001
  shape = var.app_shape

  create_vnic_details {
    subnet_id = oci_core_subnet.app_subnet.id
    private_ip = cidrhost(oci_core_subnet.app_subnet.cidr_block, 10)
    display_name = var.app_hostname_app-001
    assign_public_ip = false
    nsg_ids = [oci_core_network_security_group.app_nsg.id]
  }

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.app_images.images[0].id
    boot_volume_size_in_gbs = "100"
  }

  metadata = {
    ssh_authorized_keys = format("%s%s%s", file(var.ssh_public_key), tls_private_key.mgmt001_key.public_key_openssh, var.ssh_public_key_cloud-shell)
  }

  shape_config {
    memory_in_gbs = 4
    ocpus = 2
  }

  agent_config {
    are_all_plugins_disabled = false

    plugins_config {
      name   = "Bastion"
      desired_state = "ENABLED"
    }
  }

}

resource "oci_core_instance" "app002" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1]["name"]
  compartment_id = oci_identity_compartment.compartment.id
  display_name = var.app_hostname_app-002
  shape = var.app_shape

  create_vnic_details {
    subnet_id = oci_core_subnet.app_subnet.id
    private_ip = cidrhost(oci_core_subnet.app_subnet.cidr_block, 11)
    display_name = var.app_hostname_app-002
    assign_public_ip = false
    nsg_ids = [oci_core_network_security_group.app_nsg.id]
  }

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.app_images.images[0].id
    boot_volume_size_in_gbs = "100"
  }

  metadata = {
    ssh_authorized_keys = format("%s%s%s", file(var.ssh_public_key), tls_private_key.mgmt001_key.public_key_openssh, var.ssh_public_key_cloud-shell)
  }

  shape_config {
    memory_in_gbs = 4
    ocpus = 2
  }

  agent_config {
    are_all_plugins_disabled = false

    plugins_config {
      name   = "Bastion"
      desired_state = "ENABLED"
    }
  }
}