##################################################
# Get list of availability domains
##################################################

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

##################################################
# Gets a list of supported images based on the shape, operating system and operating system version provided
##################################################

data "oci_core_images" "images" {
  compartment_id = oci_identity_compartment.playground-compartment.id
  operating_system = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape = var.instance_shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

##################################################
# Gets list of options for service gateway
##################################################

data "oci_core_services" "services" {
}
