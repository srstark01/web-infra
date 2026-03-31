// Return created load balancer details so parent stacks can compose on top.
output "id" {
  description = "Created load balancer OCID."
  value       = oci_load_balancer_load_balancer.this.id
}

output "public_ips" {
  description = "Public IP addresses assigned to the load balancer."
  value       = [for detail in oci_load_balancer_load_balancer.this.ip_address_details : detail.ip_address]
}

output "certificate_name" {
  description = "Certificate name attached to the load balancer."
  value       = oci_load_balancer_certificate.this[0].certificate_name
}
