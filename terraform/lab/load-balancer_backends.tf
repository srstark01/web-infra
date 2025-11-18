# resource "oci_load_balancer_backend" "backend_mgmt" {
#   for_each = {
#     for triplet in flatten([
#       for svc_name in try(var.envs.mgmt.backends.services, []) : [
#         for node in try(var.envs.mgmt.backends.nodes, []) : {
#           key   = "mgmt:${svc_name}:${node}"
#           value = {
#             env       = "mgmt"
#             svc_name  = svc_name
#             svc       = one([for s in var.services : s if s.name == svc_name])
#             node      = node
#           }
#         }
#       ]
#     ]) : triplet.key => triplet.value
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
#   backendset_name  = oci_load_balancer_backend_set.backend_set_mgmt["mgmt:${each.value.svc_name}"].name
#   ip_address       = oci_core_instance.instance_mgmt[each.value.node].private_ip
#   port             = each.value.svc.port
# }

# resource "oci_load_balancer_backend" "backend_app" {
#   for_each = {
#     for triplet in flatten([
#       for svc_name in try(var.envs.app.backends.services, []) : [
#         for node in try(var.envs.app.backends.nodes, []) : {
#           key   = "app:${svc_name}:${node}"
#           value = {
#             env       = "app"
#             svc_name  = svc_name
#             svc       = one([for s in var.services : s if s.name == svc_name])
#             node      = node
#           }
#         }
#       ]
#     ]) : triplet.key => triplet.value
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
#   backendset_name  = oci_load_balancer_backend_set.backend_set_app["app:${each.value.svc_name}"].name
#   ip_address       = oci_core_instance.instance_app[each.value.node].private_ip
#   port             = each.value.svc.port
# }

# resource "oci_load_balancer_backend" "backend_stg" {
#   for_each = {
#     for triplet in flatten([
#       for svc_name in try(var.envs.stg.backends.services, []) : [
#         for node in try(var.envs.stg.backends.nodes, []) : {
#           key   = "stg:${svc_name}:${node}"
#           value = {
#             env       = "stg"
#             svc_name  = svc_name
#             svc       = one([for s in var.services : s if s.name == svc_name])
#             node      = node
#           }
#         }
#       ]
#     ]) : triplet.key => triplet.value
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
#   backendset_name  = oci_load_balancer_backend_set.backend_set_stg["stg:${each.value.svc_name}"].name
#   ip_address       = oci_core_instance.instance_stg[each.value.node].private_ip
#   port             = each.value.svc.port
# }


########################################
# MGMT – Jenkins on mgmt-001
########################################
resource "oci_load_balancer_backend" "jenkins_mgmt_001" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.jenkins_mgmt.name

  ip_address = oci_core_instance.instance_mgmt["mgmt-001"].private_ip
  port       = 8080  # adjust if Jenkins listens on a different port
}

########################################
# STG – Abidex on stg-001
########################################
resource "oci_load_balancer_backend" "abidex_stg_001" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.abidex_stg.name

  ip_address = oci_core_instance.instance_stg["stg-001"].private_ip
  port       = 8000  # Abidex STG container/web port
}

########################################
# STG – Portfolio on stg-001
########################################
resource "oci_load_balancer_backend" "portfolio_stg_001" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.portfolio_stg.name

  ip_address = oci_core_instance.instance_stg["stg-001"].private_ip
  port       = 8001
}

########################################
# APP – Abidex PROD on app-001 and app-002
########################################
resource "oci_load_balancer_backend" "abidex_prod_app_001" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.abidex_prod.name

  ip_address = oci_core_instance.instance_app["app-001"].private_ip
  port       = 8000  # Abidex PROD port
}

resource "oci_load_balancer_backend" "abidex_prod_app_002" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.abidex_prod.name

  ip_address = oci_core_instance.instance_app["app-002"].private_ip
  port       = 8000  # Abidex PROD port
}

########################################
# APP – Portfolio on app-001 and app-002
########################################
resource "oci_load_balancer_backend" "portfolio_prod_app_001" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.portfolio_prod.name

  ip_address = oci_core_instance.instance_app["app-001"].private_ip
  port       = 8001  # adjust if Portfolio uses a different port
}

resource "oci_load_balancer_backend" "portfolio_prod_app_002" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.portfolio_prod.name

  ip_address = oci_core_instance.instance_app["app-002"].private_ip
  port       = 8001  # adjust if needed
}
