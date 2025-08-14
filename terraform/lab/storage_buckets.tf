# resource "oci_objectstorage_bucket" "bucket" {
#   compartment_id = oci_identity_compartment.compartment.id
#   name           = "${var.compartment_name}_bucket"
#   namespace      = data.oci_objectstorage_namespace.ns.namespace
#   storage_tier   = "Standard"
#   access_type    = "NoPublicAccess"
#   metadata       = {}
# }

resource "oci_objectstorage_object" "tfvars" {
  namespace    = "ax7otv4piohp"
  bucket       = "myBucket"
  object       = "terraform/vars/lab.tfvars"
  content_type = "text/plain"
  source       = "${path.module}/terraform.tfvars"
}

resource "oci_objectstorage_object" "backup" {
  namespace    = "ax7otv4piohp"
  bucket       = "myBucket"
  object       = "terraform/backups/lab.tfstate.backup"
  content_type = "text/plain"
  source       = "${path.module}/terraform.tfstate.backup"
}