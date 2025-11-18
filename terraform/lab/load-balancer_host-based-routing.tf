# resource "oci_load_balancer_load_balancer_routing_policy" "host_based" {
#   for_each = { "primary" = {} }
#   name             = "${var.compartment_name}_host_based_routing_${each.key}"
#   load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
#   condition_language_version = "V1"

#   dynamic "rules" {
#     for_each = {
#       for pair in flatten([
#         for svc in var.services : [
#           for env, fqdn in try(svc.fqdns, {}) : {
#             key   = "${env}:${svc.name}"
#             value = { env = env, fqdn = fqdn, svc_name = svc.name }
#           }
#         ]
#       ]) : pair.key => pair.value
#     }

#     content {
#       name      = replace("${rules.value.env}_${rules.value.svc_name}", ".", "_")
#       # keep your V1 condition form:
#       condition = "all(http.request.headers[(i 'Host')] eq (i '${rules.value.fqdn}'))"

#       actions {
#         name             = "FORWARD_TO_BACKENDSET"
#         backend_set_name = "${var.compartment_name}_backend-set_${rules.value.svc_name}_${rules.value.env}"
#       }
#     }
#   }
# }

resource "oci_load_balancer_load_balancer_routing_policy" "host_based" {
  name                       = "${var.compartment_name}_host_based_routing"
  load_balancer_id           = oci_load_balancer_load_balancer.load_balancer.id
  condition_language_version = "V1"

  depends_on = [
    oci_load_balancer_backend_set.abidex_stg,
    oci_load_balancer_backend_set.abidex_prod,
    oci_load_balancer_backend_set.jenkins_mgmt,
    oci_load_balancer_backend_set.portfolio_stg,
    oci_load_balancer_backend_set.portfolio_prod,
  ]

  # Abidex – STG
  rules {
    name      = "stg_abidex"
    condition = "all(http.request.headers[(i 'Host')] eq (i '${var.web_svc_abidex_stg}'))"

    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = "${var.compartment_name}_backend-set_abidex_stg"
    }
  }

  # Abidex – PROD
  rules {
    name      = "prod_abidex"
    condition = "all(http.request.headers[(i 'Host')] eq (i '${var.web_svc_abidex_prod}'))"

    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = "${var.compartment_name}_backend-set_abidex_prod"
    }
  }

  # Jenkins – PROD
  rules {
    name      = "mgmt_jenkins"
    condition = "all(http.request.headers[(i 'Host')] eq (i '${var.web_svc_jenkins_mgmt}'))"

    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = "${var.compartment_name}_backend-set_jenkins_mgmt"
    }
  }

  # Portfolio / shawnstark.net – STG
  rules {
    name      = "stg_portfolio"
    condition = "all(http.request.headers[(i 'Host')] eq (i '${var.web_svc_portfolio_stg}'))"

    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = "${var.compartment_name}_backend-set_portfolio_stg"
    }
  }

  # Portfolio / shawnstark.net – PROD
  rules {
    name      = "prod_portfolio"
    condition = "all(http.request.headers[(i 'Host')] eq (i '${var.web_svc_portfolio_prod}'))"

    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = "${var.compartment_name}_backend-set_portfolio_prod"
    }
  }
}
