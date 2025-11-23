variable "ocid_tenancy" {type = string}
variable "ocid_compartment" {type = string}

variable "ssh_private_key" {type = string}
variable "ssh_public_key" {type = string}
variable "ssh_public_key_cloud-shell" {type = string}

variable "local_pub_ip" {type = string}

variable "region" {type = string}

variable "vcn_net" {type = string}
variable "vcn_dns" {type = string}

variable "compartment_name" {type = string}

variable "backend_namespace" {type = string}

variable "comments_bucket"      { type = string}
variable "iam_username"     { type = string}
variable "iam_user_email"     { type = string}
variable "retention_days"   { type = number}

variable "web_svc_abidex_stg"     { type = string}
variable "web_svc_abidex_prod"     { type = string}
variable "web_svc_jenkins_mgmt"     { type = string}
variable "web_svc_portfolio_stg"     { type = string}
variable "web_svc_portfolio_prod"     { type = string}

variable "db-001_address"     { type = string}

variable "my_dns"     { type = string}

variable "adb_name" { type = string }
variable "adb_display_name" { type = string }
variable "adb_admin_password" { type = string }
variable "adb_version" { type = string }
variable "adb_wallet_password" { type = string }

variable "local_wallet_dir" { type = string }

variable "db_subnet_name" { type = string }
variable "db_subnet_block" { type = string }
variable "db_dns" { type = string }

variable "mgmt_dns" { type = string }
variable "mgmt_user" { type = string }

variable "app_dns" { type = string }

variable "stg_dns" { type = string }

variable "default_route" { type = string }

variable "svc_gw_all" { type = string }

variable "services" {type = list(object({
  name     = string
  policy   = string
  protocol = string                 # "HTTP" | "HTTPS" | "TCP"
  url_path = string
  port     = number
  fqdns    = map(string)   
}))}

variable "envs" {
  description = "Per‑environment config (subnet bits/net, optional nodes and routes)."
  type = map(object({
    bits       = number
    net        = number
    node_shape = optional(string)
    disk_size  = optional(number)
    mem        = optional(number)
    cpu        = optional(number)
    user       = optional(string)
    os       = optional(string)
    os_version       = optional(string)

    # Optional list of nodes per env
    nodes = optional(list(object({
      name   = string
      ad     = number         # 0-based index into availability_domains
      ip     = number         # host offset, e.g., 10 -> cidrhost(..., 10)
      public = bool
    })))

    backends = optional(object({
      services    = list(string)  
      nodes    = list(string)             # instance names under this env, e.g. ["app-001","app-002"]
    }))

    # Optional map of route entries (keys like "default", "service", "internet-gw", etc.)
    routes = optional(map(object({
      destination       = string              # e.g. "0.0.0.0/0" or "oci-phx-objectstorage" or "all-phx-services-in-oracle-services-network"
      destination_type  = string              # "CIDR_BLOCK" | "SERVICE_CIDR_BLOCK"
      network_entity_id = string              # your selector string: "internet-gw" | "nat-gw" | "service-all" | "service-storage" ...
      description       = optional(string)
    })))

    nsg_rules = optional(list(object({
      name            = string
      direction       = string              # "INGRESS" | "EGRESS"
      protocol        = number              # "6"=TCP, "17"=UDP, "1"=ICMP, "all"="all"

      # For INGRESS rules use source/source_type; for EGRESS use destination/destination_type
      source          = string
      source_type     = string    # "CIDR_BLOCK" | "NETWORK_SECURITY_GROUP"
      destination     = string
      destination_type= string    # "CIDR_BLOCK" | "NETWORK_SECURITY_GROUP"

      # Ports (optional). Common case: destination port range.
      tcp_destination_port_min = number
      tcp_destination_port_max = number
      udp_destination_port_min = number
      udp_destination_port_max = number
    })))
  }))
}