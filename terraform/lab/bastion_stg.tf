resource "oci_bastion_bastion" "stg_bastion" {
    bastion_type = "STANDARD"
    compartment_id = oci_identity_compartment.compartment.id
    target_subnet_id = oci_core_subnet.stg_subnet.id
    client_cidr_block_allow_list = [var.local_pub_ip]
    name = var.stg_bastion_name
}