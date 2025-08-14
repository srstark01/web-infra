resource "oci_load_balancer_backend" "backend" {
  for_each = {
    for triplet in flatten([
      for env, cfg in var.envs : [
        for svc_name in try(cfg.backends.services, []) : [
          for node in try(cfg.backends.nodes, []) : {
            key   = "${env}:${svc_name}:${node}"
            value = {
              env       = env
              svc_name  = svc_name
              svc       = one([for s in var.services : s if s.name == svc_name])
              node      = node
            }
          }
        ]
      ]
    ]) : triplet.key => triplet.value
  }

  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.backend_set["${each.value.env}:${each.value.svc_name}"].name
  ip_address       = oci_core_instance.instance["${each.value.env}:${each.value.node}"].private_ip
  port             = each.value.svc.port
}