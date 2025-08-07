resource "oci_load_balancer_load_balancer_routing_policy" "host_based_routing" {
  name = "host_routing_${var.compartment_name}"
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id

  rules {
    name = "route_to_portfolio_stg"
    condition = "all(http.request.headers[(i 'Host')] eq (i 'stage.shawnstark.net'))"
    actions {
      name = "FORWARD_TO_BACKENDSET"
      backend_set_name  = oci_load_balancer_backend_set.backend-set-portfolio-stg.name
    }
  }

  rules {
    name = "route_to_abidex_stg"
    condition = "all(http.request.headers[(i 'Host')] eq (i 'stage.abidex.org'))"
    
    actions {
      name= "FORWARD_TO_BACKENDSET"
      backend_set_name  = oci_load_balancer_backend_set.backend-set-abidex-stg.name
    }
  }

  rules {
    name = "route_to_jenkins"
    condition = "all(http.request.headers[(i 'Host')] eq (i 'jenkins.shawnstark.net'))"
    actions {
      name = "FORWARD_TO_BACKENDSET"
      backend_set_name  = oci_load_balancer_backend_set.backend-set-jenkins-mgmt.name
    }
  }

  rules {
    name = "route_to_portfolio"
    condition = "all(http.request.headers[(i 'Host')] eq (i 'shawnstark.net'))"
    actions {
      name = "FORWARD_TO_BACKENDSET"
      backend_set_name  = oci_load_balancer_backend_set.backend-set-portfolio.name
    }
  }

  rules {
    name = "route_to_abidex"
    condition = "all(http.request.headers[(i 'Host')] eq (i 'abidex.org'))"
    
    actions {
      name= "FORWARD_TO_BACKENDSET"
      backend_set_name  = oci_load_balancer_backend_set.backend-set-abidex.name
    }
  }

  condition_language_version = "V1"
}