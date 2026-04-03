// Reusable OCI Autonomous Database building block.
resource "oci_database_autonomous_database" "this" {
  compartment_id = var.compartment_id

  display_name = var.display_name
  db_name      = var.db_name
  secret_id    = var.admin_password_secret_id

  db_workload     = var.db_workload
  db_version      = var.db_version
  is_free_tier    = var.is_free_tier
  license_model   = var.license_model
  whitelisted_ips = var.whitelisted_ips

  secret_version_number = var.admin_password_secret_version_number
}
