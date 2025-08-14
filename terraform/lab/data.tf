data "oci_identity_availability_domains" "ads" {
  compartment_id = var.ocid_tenancy
}

data "oci_core_images" "os_images" {
  for_each = { for k, v in var.envs : k => v if try(v.os, null) != null }
  compartment_id = var.ocid_compartment
  operating_system = each.value.os
}

data "oci_core_images" "images" {
  for_each = { for k, v in var.envs : k => v if try(v.os, null) != null }
  compartment_id = oci_identity_compartment.compartment.id
  operating_system = each.value.os
  operating_system_version = each.value.os_version
  shape = each.value.node_shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

data "oci_core_services" "services" {
}

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.ocid_tenancy   # tenancy OCID
}