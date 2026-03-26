terraform {
  // Require a modern Terraform CLI version for this stack.
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      // Keep the OCI provider within a compatible release series.
      source  = "oracle/oci"
      version = "~> 7.22"
    }
  }
}
