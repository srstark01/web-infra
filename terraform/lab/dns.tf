# # resource "oci_dns_rrset" "comments_db_primary" {
# #   compartment_id = oci_identity_compartment.compartment.id

# #   # Use the existing private zone by NAME, not OCID
# #   zone_name_or_id = "db.${var.vcn_dns}.oraclevcn.com"

# #   # FQDN inside that zone
# #   domain = "comments-db-primary.db.${var.vcn_dns}.oraclevcn.com"
# #   rtype  = "A"

# #   scope = "PRIVATE"

# #   items {
# #     domain = "comments-db-primary.db.${var.vcn_dns}.oraclevcn.com"
# #     rdata  = var.db-001_address  # db-001 for now
# #     rtype  = "A"
# #     ttl    = 5             # low TTL for quick failover later
# #   }
# # }

# # Look up the existing private DB zone by name and get its OCID
# data "oci_dns_zones" "db_zone" {
#   compartment_id = oci_identity_compartment.compartment.id

#   name  = "db.${var.vcn_dns}.oraclevcn.com"
#   scope = "PRIVATE"
# }

# resource "oci_dns_rrset" "comments_db_primary" {
#   compartment_id   = oci_identity_compartment.compartment.id

#   # Use the zone OCID so we DON'T need view_id
#   zone_name_or_id  = data.oci_dns_zones.db_zone.zones[0].id
#   domain           = "comments-db-primary.db.${var.vcn_dns}.oraclevcn.com"
#   rtype            = "A"
#   scope            = "PRIVATE"

#   items {
#     domain = "comments-db-primary.db.${var.vcn_dns}.oraclevcn.com"
#     rtype  = "A"
#     rdata  = var.db-001_address   # primary DB IP
#     ttl    = 30
#   }
# }

# Look up the existing private DNS view for the lab VCN
data "oci_dns_views" "lab_view" {
  compartment_id = oci_identity_compartment.compartment.id
  scope          = "PRIVATE"
  display_name   = "${var.compartment_name}_vcn_${var.vcn_dns}"
}

#######################################
# Private zone: srstark.com (internal)
#######################################
resource "oci_dns_zone" "srstark_com_private" {
  compartment_id = oci_identity_compartment.compartment.id

  name      = var.my_dns
  zone_type = "PRIMARY"
  scope     = "PRIVATE"

  # Attach to the existing lab VCN DNS view
  view_id = data.oci_dns_views.lab_view.views[0].id
}

#######################################
# A record: comments-db-primary.srstark.com
#######################################
resource "oci_dns_rrset" "comments_db_primary" {
  compartment_id  = oci_identity_compartment.compartment.id

  # Use the zone *ID* so we don't need view_id here
  zone_name_or_id = oci_dns_zone.srstark_com_private.id

  domain = "comments-db-primary.${var.my_dns}"
  rtype  = "A"
  scope  = "PRIVATE"

  items {
    domain = "comments-db-primary.${var.my_dns}"
    rtype  = "A"
    rdata  = var.db-001_address   # db-001 for now
    ttl    = 5
  }
}
