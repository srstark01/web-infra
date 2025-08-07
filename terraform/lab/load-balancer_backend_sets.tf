resource "oci_load_balancer_backend_set" "backend-set-abidex" {
  name = "backend-set-abidex-${var.compartment_name}"
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  policy = "LEAST_CONNECTIONS"

  health_checker {
    protocol = "HTTP"
    url_path = "/home"
    port     = 8000
  }
}
resource "oci_load_balancer_backend_set" "backend-set-portfolio" {
  name = "backend-set-portfolio-${var.compartment_name}"
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  policy = "LEAST_CONNECTIONS"

  health_checker {
    protocol = "HTTP"
    url_path = "/home"
    port     = 8001
  }
}

resource "oci_load_balancer_backend_set" "backend-set-abidex-stg" {
  name = "backend-set-abidex-${var.stg_dns}-${var.compartment_name}"
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  policy = "LEAST_CONNECTIONS"

  health_checker {
    protocol = "HTTP"
    url_path = "/home"
    port     = 8000
  }
}

resource "oci_load_balancer_backend_set" "backend-set-portfolio-stg" {
  name = "backend-set-portfolio-${var.stg_dns}-${var.compartment_name}"
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  policy = "LEAST_CONNECTIONS"

  health_checker {
    protocol = "HTTP"
    url_path = "/home"
    port     = 8001
  }
}

resource "oci_load_balancer_backend_set" "backend-set-jenkins-mgmt" {
  name = "backend-set-jenkins-${var.mgmt_dns}-${var.compartment_name}"
  load_balancer_id = oci_load_balancer_load_balancer.load-balancer.id
  policy = "LEAST_CONNECTIONS"

  health_checker {
    protocol = "HTTP"
    url_path = "/login"
    port     = 8080
  }
}