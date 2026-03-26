// Return created NSG details so parent stacks can compose on top.
output "id" {
  description = "Created NSG OCID."
  value       = oci_core_network_security_group.this.id
}
