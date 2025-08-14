resource "oci_objectstorage_bucket" "bucket" {
  compartment_id = oci_identity_compartment.compartment.id
  name           = "${var.compartment_name}_bucket"
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  storage_tier   = "Standard"
  access_type    = "NoPublicAccess"
  metadata       = {}
}