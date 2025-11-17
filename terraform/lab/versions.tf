# terraform {
#   required_providers {
#     oci = {
#       source  = "oracle/oci"
#       version = ">=4.67.3"
#     }
#   }
#   required_version = ">= 1.0.0"
# }

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.22"  # or latest stable in your pipeline
    }
  }
}
