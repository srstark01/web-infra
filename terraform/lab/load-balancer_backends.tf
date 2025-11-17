resource "oci_load_balancer_backend" "backend_mgmt" {
  for_each = {
    for triplet in flatten([
      for svc_name in try(var.envs.mgmt.backends.services, []) : [
        for node in try(var.envs.mgmt.backends.nodes, []) : {
          key   = "mgmt:${svc_name}:${node}"
          value = {
            env       = "mgmt"
            svc_name  = svc_name
            svc       = one([for s in var.services : s if s.name == svc_name])
            node      = node
          }
        }
      ]
    ]) : triplet.key => triplet.value
  }

  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.backend_set_mgmt["mgmt:${each.value.svc_name}"].name
  ip_address       = oci_core_instance.instance_mgmt[each.value.node].private_ip
  port             = each.value.svc.port
}

resource "oci_load_balancer_backend" "backend_app" {
  for_each = {
    for triplet in flatten([
      for svc_name in try(var.envs.app.backends.services, []) : [
        for node in try(var.envs.app.backends.nodes, []) : {
          key   = "app:${svc_name}:${node}"
          value = {
            env       = "app"
            svc_name  = svc_name
            svc       = one([for s in var.services : s if s.name == svc_name])
            node      = node
          }
        }
      ]
    ]) : triplet.key => triplet.value
  }

  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.backend_set_app["app:${each.value.svc_name}"].name
  ip_address       = oci_core_instance.instance_app[each.value.node].private_ip
  port             = each.value.svc.port
}

resource "oci_load_balancer_backend" "backend_stg" {
  for_each = {
    for triplet in flatten([
      for svc_name in try(var.envs.stg.backends.services, []) : [
        for node in try(var.envs.stg.backends.nodes, []) : {
          key   = "stg:${svc_name}:${node}"
          value = {
            env       = "stg"
            svc_name  = svc_name
            svc       = one([for s in var.services : s if s.name == svc_name])
            node      = node
          }
        }
      ]
    ]) : triplet.key => triplet.value
  }

  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.backend_set_stg["stg:${each.value.svc_name}"].name
  ip_address       = oci_core_instance.instance_stg[each.value.node].private_ip
  port             = each.value.svc.port
}
