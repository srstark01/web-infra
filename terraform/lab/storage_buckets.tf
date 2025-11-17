# resource "oci_objectstorage_bucket" "bucket" {
#   compartment_id = oci_identity_compartment.compartment.id
#   name           = "${var.compartment_name}_bucket"
#   namespace      = data.oci_objectstorage_namespace.ns.namespace
#   storage_tier   = "Standard"
#   access_type    = "NoPublicAccess"
#   metadata       = {}
# }

resource "oci_objectstorage_object" "tfvars" {
  namespace    = data.oci_objectstorage_namespace.tenancy_ns.namespace
  bucket       = "myBucket"
  object       = "terraform/vars/lab.tfvars"
  content_type = "text/plain"
  source       = "${path.module}/terraform.tfvars"
}

resource "oci_objectstorage_object" "backup" {
  namespace    = data.oci_objectstorage_namespace.tenancy_ns.namespace
  bucket       = "myBucket"
  object       = "terraform/backups/lab.tfstate.backup"
  content_type = "text/plain"
  source       = "${path.module}/terraform.tfstate.backup"
}

# # --- Object Storage bucket (versioning ON for PITR) ---
# resource "oci_objectstorage_bucket" "comments" {
#   compartment_id = var.ocid_compartment
#   name           = var.comments_bucket
#   namespace      = data.oci_objectstorage_namespace.compartment_ns.namespace
#   storage_tier   = "Standard"
#   versioning     = "Enabled"   # important for Litestream retention & rewind
#   auto_tiering   = "InfrequentAccess"  # optional cost saver
# }

# # Optional: lifecycle to prune old replicas (keep last N days)
# resource "oci_objectstorage_object_lifecycle_policy" "comments" {
#   namespace = data.oci_objectstorage_namespace.compartment_ns.namespace
#   bucket    = oci_objectstorage_bucket.comments.name

#   rules {
#     name        = "expire-old-replicas"
#     action      = "DELETE"
#     is_enabled  = true
#     time_amount = var.retention_days
#     time_unit   = "DAYS"
#     # scope all objects (Litestream manages layout under a prefix)
#   }

#   depends_on = [oci_identity_policy.objstore_service_manage_objects]
# }

# resource "oci_identity_group" "litestream_group" {
#   compartment_id = var.ocid_compartment
#   name           = "litestream-repl"
#   description    = "Group with object access for Litestream"
# }

# resource "oci_identity_user_group_membership" "litestream_membership" {
#   user_id  = oci_identity_user.litestream_user.id
#   group_id = oci_identity_group.litestream_group.id
# }

# # Policy: allow reads/writes to objects in the bucket’s compartment
# resource "oci_identity_policy" "litestream_policy" {
#   compartment_id = var.ocid_compartment
#   name           = "litestream-object-access"
#   description    = "Allow Litestream user to manage objects in this compartment"
#   statements = [
#     "Allow group ${oci_identity_group.litestream_group.name} to manage objects in compartment id ${var.ocid_compartment}",
#     "Allow group ${oci_identity_group.litestream_group.name} to read buckets in compartment id ${var.ocid_compartment}"
#   ]
# }

# # Customer Secret Key (S3 credentials) for the user
# resource "oci_identity_customer_secret_key" "litestream_key" {
#   user_id = oci_identity_user.litestream_user.id
#   display_name = "litestream-s3"
# }

# # --- Useful outputs ---
# output "object_namespace" {
#   value = data.oci_objectstorage_namespace.compartment_ns.namespace
# }

# output "bucket_name" {
#   value = oci_objectstorage_bucket.comments.name
# }

# output "s3_endpoint" {
#   value = "https://${data.oci_objectstorage_namespace.compartment_ns.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
# }

# # Sensitive: store via your secret manager or copy to Ansible Vault
# output "s3_access_key_id" {
#   value     = oci_identity_customer_secret_key.litestream_key.id
#   sensitive = true
# }

# output "s3_secret_access_key" {
#   value     = oci_identity_customer_secret_key.litestream_key.key
#   sensitive = true
# }
