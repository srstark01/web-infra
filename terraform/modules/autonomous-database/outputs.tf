// Return created Autonomous Database details so parent stacks can compose on top.
output "id" {
  description = "Created Autonomous Database OCID."
  value       = oci_database_autonomous_database.this.id
}

output "display_name" {
  description = "Created Autonomous Database display name."
  value       = oci_database_autonomous_database.this.display_name
}

output "db_name" {
  description = "Created Autonomous Database name."
  value       = oci_database_autonomous_database.this.db_name
}

output "whitelisted_ips" {
  description = "Public IP allowlist applied to the Autonomous Database."
  value       = oci_database_autonomous_database.this.whitelisted_ips
}
