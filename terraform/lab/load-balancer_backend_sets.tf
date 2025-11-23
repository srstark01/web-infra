# resource "oci_load_balancer_backend_set" "backend_set_mgmt" {
#   for_each = {
#     for svc_name in try(var.envs.mgmt.backends.services, []) :
#     "mgmt:${svc_name}" => {
#       env = "mgmt"
#       svc = one([for s in var.services : s if s.name == svc_name])
#     }
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
#   name             = "${var.compartment_name}_backend-set_${each.value.svc.name}_${each.value.env}"
#   policy           = each.value.svc.policy

#   health_checker {
#     protocol = upper(each.value.svc.protocol)   # "HTTP"|"HTTPS"|"TCP"
#     port     = each.value.svc.port
#     url_path = each.value.svc.url_path
#   }
# }

# resource "oci_load_balancer_backend_set" "backend_set_app" {
#   for_each = {
#     for svc_name in try(var.envs.app.backends.services, []) :
#     "app:${svc_name}" => {
#       env = "app"
#       svc = one([for s in var.services : s if s.name == svc_name])
#     }
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
#   name             = "${var.compartment_name}_backend-set_${each.value.svc.name}_${each.value.env}"
#   policy           = each.value.svc.policy

#   health_checker {
#     protocol = upper(each.value.svc.protocol)   # "HTTP"|"HTTPS"|"TCP"
#     port     = each.value.svc.port
#     url_path = each.value.svc.url_path
#   }
# }

# resource "oci_load_balancer_backend_set" "backend_set_stg" {
#   for_each = {
#     for svc_name in try(var.envs.stg.backends.services, []) :
#     "stg:${svc_name}" => {
#       env = "stg"
#       svc = one([for s in var.services : s if s.name == svc_name])
#     }
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
#   name             = "${var.compartment_name}_backend-set_${each.value.svc.name}_${each.value.env}"
#   policy           = each.value.svc.policy

#   health_checker {
#     protocol = upper(each.value.svc.protocol)   # "HTTP"|"HTTPS"|"TCP"
#     port     = each.value.svc.port
#     url_path = each.value.svc.url_path
#   }
# }

########################################
# Backend sets – explicit, no loops
########################################

# Abidex – STG
resource "oci_load_balancer_backend_set" "abidex_stg" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "${var.compartment_name}_backend-set_abidex_stg"
  policy           = "ROUND_ROBIN" # adjust if needed

  health_checker {
    protocol = "HTTP"              # or "HTTPS" / "TCP"
    port     = 8000                # <- set to abidex STG port
    url_path = "/home"          # <- set to your actual health endpoint
  }
}

# Abidex – PROD
resource "oci_load_balancer_backend_set" "abidex_prod" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "${var.compartment_name}_backend-set_abidex_prod"
  policy           = "ROUND_ROBIN" # adjust if needed

  health_checker {
    protocol = "HTTP"
    port     = 8000                # <- abidex PROD port
    url_path = "/home"          # <- abidex PROD health path
  }
}

# Jenkins – MGMT
resource "oci_load_balancer_backend_set" "jenkins_mgmt" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "${var.compartment_name}_backend-set_jenkins_mgmt"
  policy           = "ROUND_ROBIN" # or whatever you were using

  health_checker {
    protocol = "HTTP"
    port     = 8080                # typical Jenkins port; change if different
    url_path = "/login"                 # or "/login" if you prefer
  }
}

# Portfolio – STG
resource "oci_load_balancer_backend_set" "portfolio_stg" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "${var.compartment_name}_backend-set_portfolio_stg"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    port     = 8001                # <- portfolio app port
    url_path = "/home"          # or "/" or whatever you use
  }
}

# Portfolio – PROD
resource "oci_load_balancer_backend_set" "portfolio_prod" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "${var.compartment_name}_backend-set_portfolio_prod"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    port     = 8001                # <- portfolio app port
    url_path = "/home"          # or "/" or whatever you use
  }
}