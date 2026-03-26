// Return created instance details so parent stacks can compose on top.
output "id" {
  description = "Created instance OCID."
  value       = oci_core_instance.this.id
}

output "display_name" {
  description = "Created instance display name."
  value       = oci_core_instance.this.display_name
}

output "private_ip" {
  description = "Primary private IP address."
  value       = data.oci_core_vnic.primary.private_ip_address
}

output "public_ip" {
  description = "Primary public IP address, if assigned."
  value       = data.oci_core_vnic.primary.public_ip_address
}
