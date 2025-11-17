resource "oci_load_balancer_backend_set" "backend_set_mgmt" {
  for_each = {
    for svc_name in try(var.envs.mgmt.backends.services, []) :
    "mgmt:${svc_name}" => {
      env = "mgmt"
      svc = one([for s in var.services : s if s.name == svc_name])
    }
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

resource "oci_load_balancer_backend_set" "backend_set_app" {
  for_each = {
    for svc_name in try(var.envs.app.backends.services, []) :
    "app:${svc_name}" => {
      env = "app"
      svc = one([for s in var.services : s if s.name == svc_name])
    }
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

resource "oci_load_balancer_backend_set" "backend_set_stg" {
  for_each = {
    for svc_name in try(var.envs.stg.backends.services, []) :
    "stg:${svc_name}" => {
      env = "stg"
      svc = one([for s in var.services : s if s.name == svc_name])
    }
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