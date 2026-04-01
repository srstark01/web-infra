// Inputs accepted by the reusable OCI NSG rule attachment module.
variable "network_security_group_id" {
  description = "OCID of the NSG to attach rules to."
  type        = string
}

variable "rules" {
  description = "Security rules to create on the target NSG."
  type = list(object({
    description = string
    direction   = string
    protocol    = string
    target      = string
    target_type = string
    stateless   = optional(bool, false)
    tcp_port_range = optional(object({
      min = number
      max = number
    }), null)
  }))
  default = []
}
