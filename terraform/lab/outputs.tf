output "all-availability-domains-in-your-tenancy" {
  value = data.oci_identity_availability_domains.ads.availability_domains
  }

output "app_os_images" {
  value = data.oci_core_images.os_images
  }

output "app_images" {
  value = data.oci_core_images.app_images
  }