resource "oci_load_balancer_load_balancer" "load_balancer" {
    compartment_id = oci_identity_compartment.compartment.id
    display_name = "${var.compartment_name}_load-balancer"
    shape = "flexible"
    network_security_group_ids = [
        oci_core_network_security_group.nsg["pub"].id
    ]
    subnet_ids = [
      oci_core_subnet.subnet["pub"].id
    ]
    shape_details {
        maximum_bandwidth_in_mbps = "10"
        minimum_bandwidth_in_mbps = "10"
    }
}

resource "oci_load_balancer_listener" "http_80" {
  load_balancer_id    = oci_load_balancer_load_balancer.load_balancer.id
  name                = "listener-http"
  port                = 80
  protocol            = "HTTP"
  routing_policy_name = oci_load_balancer_load_balancer_routing_policy.host_based["primary"].name

  default_backend_set_name = "${var.compartment_name}_backend-set_abidex_app"
}