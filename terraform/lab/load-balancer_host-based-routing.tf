resource "oci_load_balancer_load_balancer_routing_policy" "host_based" {
  for_each = { "primary" = {} }
  name             = "${var.compartment_name}_host_based_routing_${each.key}"
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  condition_language_version = "V1"

  dynamic "rules" {
    for_each = {
      for pair in flatten([
        for svc in var.services : [
          for env, fqdn in try(svc.fqdns, {}) : {
            key   = "${env}:${svc.name}"
            value = { env = env, fqdn = fqdn, svc_name = svc.name }
          }
        ]
      ]) : pair.key => pair.value
    }

    content {
      name      = replace("${rules.value.env}_${rules.value.svc_name}", ".", "_")
      # keep your V1 condition form:
      condition = "all(http.request.headers[(i 'Host')] eq (i '${rules.value.fqdn}'))"

      actions {
        name             = "FORWARD_TO_BACKENDSET"
        backend_set_name = "${var.compartment_name}_backend-set_${rules.value.svc_name}_${rules.value.env}"
      }
    }
  }
}
