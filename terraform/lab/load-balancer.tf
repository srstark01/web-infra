resource "oci_load_balancer_load_balancer" "load-balancer" {
    # Required
    compartment_id = oci_identity_compartment.compartment.id
    display_name = "load-balancer-${var.compartment_name}"
    shape = "flexible"
    network_security_group_ids = [
        oci_core_network_security_group.pub_nsg.id
    ]
    subnet_ids = [
      oci_core_subnet.pub_subnet.id
    ]
    shape_details {
        # Required
        maximum_bandwidth_in_mbps = "10"
        minimum_bandwidth_in_mbps = "10"
    }
}

resource "oci_load_balancer_listener" "listener" {
    # Required
    default_backend_set_name = oci_load_balancer_backend_set.backend-set-abidex.name
    load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
    name = "listener-${var.compartment_name}"
    port = "80"
    protocol = "HTTP"
    routing_policy_name = oci_load_balancer_load_balancer_routing_policy.host_based_routing.name
}