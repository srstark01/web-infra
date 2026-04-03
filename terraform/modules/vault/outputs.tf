// Return created vault resources so parent stacks can compose on top.
output "vault_id" {
  description = "Created vault OCID."
  value       = oci_kms_vault.this.id
}

output "vault_management_endpoint" {
  description = "Management endpoint for the created vault."
  value       = oci_kms_vault.this.management_endpoint
}

output "key_id" {
  description = "Created KMS key OCID."
  value       = oci_kms_key.this.id
}

output "secret_ids" {
  description = "Created secret OCIDs keyed by secret name."
  value = {
    for name, secret in oci_vault_secret.this :
    name => secret.id
  }
}
