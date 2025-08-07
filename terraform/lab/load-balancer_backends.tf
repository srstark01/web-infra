resource "oci_load_balancer_backend" "backend001-abidex" {
  backendset_name  = oci_load_balancer_backend_set.backend-set-abidex.name
  ip_address       = oci_core_instance.app001.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  port             = 8000
}

resource "oci_load_balancer_backend" "backend002-abidex" {
  backendset_name  = oci_load_balancer_backend_set.backend-set-abidex.name
  ip_address       = oci_core_instance.app002.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  port             = 8000
}

resource "oci_load_balancer_backend" "backend001-portfolio" {
  backendset_name  = oci_load_balancer_backend_set.backend-set-portfolio.name
  ip_address       = oci_core_instance.app001.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  port             = 8001
}

resource "oci_load_balancer_backend" "backend002-portfolio" {
  backendset_name  = oci_load_balancer_backend_set.backend-set-portfolio.name
  ip_address       = oci_core_instance.app002.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  port             = 8001
}

resource "oci_load_balancer_backend" "backend001-abidex-stg" {
  backendset_name  = oci_load_balancer_backend_set.backend-set-abidex-stg.name
  ip_address       = oci_core_instance.stg001.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  port             = 8000
}

resource "oci_load_balancer_backend" "backend001-portfolio-stg" {
  backendset_name  = oci_load_balancer_backend_set.backend-set-portfolio-stg.name
  ip_address       = oci_core_instance.stg001.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  port             = 8001
}

resource "oci_load_balancer_backend" "backend001-jenkins-mgmt" {
  backendset_name  = oci_load_balancer_backend_set.backend-set-jenkins-mgmt.name
  ip_address       = oci_core_instance.mgmt001.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  port             = 8080
}