output "id" {
  description = "Created compartment OCID."
  value       = oci_identity_compartment.this.id
}

output "name" {
  description = "Created compartment name."
  value       = oci_identity_compartment.this.name
}
