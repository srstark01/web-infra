// Reusable OCI compute instance building block.
resource "oci_core_instance" "this" {
  availability_domain  = var.availability_domain
  compartment_id       = var.compartment_id
  display_name         = var.display_name
  shape                = var.shape
  preserve_boot_volume = var.preserve_boot_volume

  dynamic "shape_config" {
    for_each = var.shape_config == null ? [] : [var.shape_config]

    content {
      memory_in_gbs = shape_config.value.memory_in_gbs
      ocpus         = shape_config.value.ocpus
    }
  }

  create_vnic_details {
    assign_public_ip = var.assign_public_ip
    hostname_label   = var.hostname_label
    nsg_ids          = var.nsg_ids
    subnet_id        = var.subnet_id
  }

  metadata = merge(
    var.metadata,
    {
      ssh_authorized_keys = var.ssh_authorized_keys
    }
  )

  source_details {
    source_id               = var.image_id
    source_type             = "image"
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }
}

data "oci_core_vnic_attachments" "this" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  instance_id         = oci_core_instance.this.id
}

data "oci_core_vnic" "primary" {
  vnic_id = data.oci_core_vnic_attachments.this.vnic_attachments[0].vnic_id
}
