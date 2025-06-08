resource "oci_load_balancer_load_balancer" "portfolio-load-balancer" {
    # Required
    compartment_id = oci_identity_compartment.playground-compartment.id
    display_name = "portfolio-load-balancer"
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

resource "oci_load_balancer_backend_set" "portfolio-backend-set" {
    # Required
    health_checker {
        # Required
        protocol = "HTTP"
        url_path = "/"
    }
    load_balancer_id = oci_load_balancer_load_balancer.portfolio-load-balancer.id
    name = "portfolio-backend-set"
    policy = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "portfolio-backend001" {
    # Required
    backendset_name = oci_load_balancer_backend_set.portfolio-backend-set.name
    ip_address = oci_core_instance.app001.private_ip
    load_balancer_id = oci_load_balancer_load_balancer.portfolio-load-balancer.id
    port = "80"
}

resource "oci_load_balancer_backend" "portfolio-backend002" {
    # Required
    backendset_name = oci_load_balancer_backend_set.portfolio-backend-set.name
    ip_address = oci_core_instance.app002.private_ip
    load_balancer_id = oci_load_balancer_load_balancer.portfolio-load-balancer.id
    port = "80"
}

resource "oci_load_balancer_listener" "portfolio-listener" {
    # Required
    default_backend_set_name = oci_load_balancer_backend_set.portfolio-backend-set.name
    load_balancer_id = oci_load_balancer_load_balancer.portfolio-load-balancer.id
    name = "portfolio-listener"
    port = "80"
    protocol = "HTTP"
}
