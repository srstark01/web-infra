variable "ocid_tenancy" {type = string}
variable "ocid_compartment" {type = string}
variable "ocid_user" {type = string}

variable "fingerprint" {type = string}
variable "oci_private_key" {type = string}

variable "ssh_private_key" {type = string}
variable "ssh_public_key" {type = string}
variable "ssh_public_key_cloud-shell" {type = string}

variable "local_pub_ip" {type = string}

variable "region" {type = string}

variable "vcn_net" {type = string}
variable "vcn_dns" {type = string}

variable "pub_dns" {type = string}

variable "mgmt_dns" {type = string}
variable "mgmt_hostname_mgmt-001" {type = string}
variable "mgmt_bastion_name" {type = string}

variable "stg_dns" {type = string}
variable "stg_hostname_stg-001" {type = string}
variable "stg_bastion_name" {type = string}

variable "app_dns" {type = string}
variable "app_hostname_app-001" {type = string}
variable "app_hostname_app-002" {type = string}
variable "app_bastion_name" {type = string}

variable "db_dns" {type = string}

variable "route_default" {type = string}

variable "svc_gw_all" {type = string}
variable "svc_gw_storage" {type = string}

variable "app_shape" {type = string}
variable "app_os" {type = string}
variable "app_ov_version" {type = string}
variable "app_user" {type = string}

variable "mgmt_shape" {type = string}
variable "mgmt_os" {type = string}
variable "mgmt_ov_version" {type = string}
variable "mgmt_user" {type = string}

variable "stg_shape" {type = string}
variable "stg_os" {type = string}
variable "stg_ov_version" {type = string}
variable "stg_user" {type = string}

variable "compartment_name" {type = string}