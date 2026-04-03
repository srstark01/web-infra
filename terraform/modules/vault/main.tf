// Reusable OCI vault building block for environment-scoped secrets.
locals {
  secret_names = nonsensitive(toset(keys(var.secrets)))
}

resource "oci_kms_vault" "this" {
  compartment_id = var.compartment_id
  display_name   = var.vault_display_name
  vault_type     = var.vault_type
}

resource "oci_kms_key" "this" {
  compartment_id           = var.compartment_id
  display_name             = var.key_display_name
  management_endpoint      = oci_kms_vault.this.management_endpoint
  protection_mode          = var.key_protection_mode
  is_auto_rotation_enabled = var.key_is_auto_rotation_enabled

  key_shape {
    algorithm = var.key_algorithm
    length    = var.key_length
  }
}

resource "oci_vault_secret" "this" {
  for_each = local.secret_names

  compartment_id = var.compartment_id
  key_id         = oci_kms_key.this.id
  secret_name    = each.value
  vault_id       = oci_kms_vault.this.id
  description    = var.secrets[each.value].description

  enable_auto_generation = var.secrets[each.value].auto_generate

  secret_generation_context {
    generation_type     = "PASSPHRASE"
    generation_template = var.secrets[each.value].generation_template
    passphrase_length   = var.secrets[each.value].passphrase_length
  }
}
