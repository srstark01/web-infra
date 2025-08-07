##################################################
# Get list of availability domains
##################################################

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.ocid_tenancy
}

##################################################
# Gets list of options for service gateway
##################################################

data "oci_core_images" "os_images" {
  compartment_id = var.ocid_compartment
  operating_system = "Oracle Linux"
}

##################################################
# Gets a list of supported images based on the shape, operating system and operating system version provided
##################################################

data "oci_core_images" "mgmt_images" {
  compartment_id = oci_identity_compartment.compartment.id
  operating_system = var.mgmt_os
  operating_system_version = var.mgmt_ov_version
  shape = var.mgmt_shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

data "oci_core_images" "app_images" {
  compartment_id = oci_identity_compartment.compartment.id
  operating_system = var.app_os
  operating_system_version = var.app_ov_version
  shape = var.app_shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

data "oci_core_images" "stg_images" {
  compartment_id = oci_identity_compartment.compartment.id
  operating_system = var.stg_os
  operating_system_version = var.stg_ov_version
  shape = var.stg_shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

##################################################
# Gets list of options for service gateway
##################################################

data "oci_core_services" "services" {
}