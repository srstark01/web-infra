# resource "oci_database_autonomous_database" "lab_adb" {
#   compartment_id = oci_identity_compartment.compartment.id

#   display_name   = var.adb_display_name
#   db_name        = var.adb_name

#   admin_password = var.adb_admin_password

#   db_workload   = "OLTP"
#   db_version    = var.adb_version
#   is_free_tier  = true
#   license_model = "LICENSE_INCLUDED"

#   # Private endpoint only
#   subnet_id = oci_core_subnet.lab_subnet_db.id
#   nsg_ids   = [oci_core_network_security_group.db_nsg.id]

#   private_endpoint_label = "${var.compartment_name}-pe-${var.db_dns}"

#   # REMOVE this:
#   # is_access_control_enabled = false
# }

resource "oci_database_autonomous_database" "lab_adb" {
  compartment_id = oci_identity_compartment.compartment.id

  display_name   = var.adb_display_name
  db_name        = var.adb_name

  admin_password = var.adb_admin_password

  db_workload   = "OLTP"
  db_version    = var.adb_version          # e.g. "23ai"
  is_free_tier  = true                     # <-- Always Free
  license_model = "LICENSE_INCLUDED"

  # IMPORTANT:
  # For Always Free / public endpoint:
  # - DO NOT set subnet_id
  # - DO NOT set nsg_ids
  # - DO NOT set private_endpoint_label

  # Restrict external access to only these IPs
  whitelisted_ips = [oci_core_instance.instance_mgmt["mgmt-001"].public_ip]
}

resource "oci_database_autonomous_database_wallet" "lab_wallet" {
  autonomous_database_id = oci_database_autonomous_database.lab_adb.id
  password               = var.adb_wallet_password

  # <<< THIS IS THE IMPORTANT BIT
  base64_encode_content  = true
}

resource "local_file" "lab_wallet_zip" {
  filename = "${var.local_wallet_dir}/lab_adb_wallet.zip"

  # OCI now gives us base64; let local_file decode it safely to binary
  content_base64 = oci_database_autonomous_database_wallet.lab_wallet.content

  file_permission      = "0600"
  directory_permission = "0700"
}

