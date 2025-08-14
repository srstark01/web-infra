resource "oci_load_balancer_backend_set" "backend_set" {
  for_each = {
    for pair in flatten([
      for env, cfg in var.envs : [
        for svc_name in try(cfg.backends.services, []) : {
          key   = "${env}:${svc_name}"
          value = {
            env = env
            svc = one([for s in var.services : s if s.name == svc_name])
          }
        }
      ]
    ]) : pair.key => pair.value
  }

  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "${var.compartment_name}_backend-set_${each.value.svc.name}_${each.value.env}"
  policy           = each.value.svc.policy

  health_checker {
    protocol = upper(each.value.svc.protocol)   # "HTTP"|"HTTPS"|"TCP"
    port     = each.value.svc.port
    url_path = each.value.svc.url_path
  }
}