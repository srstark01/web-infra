resource "oci_bastion_bastion" "bastion" {
    for_each = var.envs
    bastion_type = "STANDARD"
    compartment_id = oci_identity_compartment.compartment.id
    target_subnet_id = oci_core_subnet.subnet[each.key].id
    client_cidr_block_allow_list = [var.local_pub_ip]
    name = "${var.compartment_name}_bastion_${each.key}"
}