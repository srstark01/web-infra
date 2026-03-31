// Reusable OCI load balancer building block for public HTTPS endpoints.

resource "tls_private_key" "this" {
  count = 1

  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "this" {
  count = 1

  private_key_pem       = tls_private_key.this[0].private_key_pem
  validity_period_hours = var.bootstrap_certificate_validity_period_hours
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]

  subject {
    common_name  = var.primary_hostname
    organization = var.bootstrap_certificate_organization
  }

  dns_names = [
    var.primary_hostname,
    var.alternate_hostname,
  ]
}

resource "oci_load_balancer_load_balancer" "this" {
  compartment_id             = var.compartment_id
  display_name               = var.display_name
  shape                      = var.shape
  subnet_ids                 = var.subnet_ids
  is_private                 = var.is_private
  network_security_group_ids = var.network_security_group_ids

  shape_details {
    minimum_bandwidth_in_mbps = var.minimum_bandwidth_in_mbps
    maximum_bandwidth_in_mbps = var.maximum_bandwidth_in_mbps
  }
}

resource "oci_load_balancer_certificate" "this" {
  count = 1

  load_balancer_id   = oci_load_balancer_load_balancer.this.id
  certificate_name   = var.bootstrap_certificate_name
  public_certificate = tls_self_signed_cert.this[0].cert_pem
  private_key        = tls_private_key.this[0].private_key_pem
}

resource "oci_load_balancer_backend_set" "primary" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = var.primary_backend_set_name
  policy           = var.backend_policy

  health_checker {
    protocol            = "HTTP"
    is_force_plain_text = var.health_check_force_plain_text
    port                = var.primary_backend_port
    url_path            = var.health_check_path
    return_code         = var.health_check_return_code
    retries             = var.health_check_retries
    interval_ms         = var.health_check_interval_ms
    timeout_in_millis   = var.health_check_timeout_in_millis
  }

  dynamic "ssl_configuration" {
    for_each = var.enable_backend_ssl ? [1] : []

    content {
      verify_peer_certificate = var.verify_backend_peer_certificate
    }
  }
}

resource "oci_load_balancer_backend_set" "alternate" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = var.alternate_backend_set_name
  policy           = var.backend_policy

  health_checker {
    protocol            = "HTTP"
    is_force_plain_text = var.health_check_force_plain_text
    port                = var.alternate_backend_port
    url_path            = var.health_check_path
    return_code         = var.health_check_return_code
    retries             = var.health_check_retries
    interval_ms         = var.health_check_interval_ms
    timeout_in_millis   = var.health_check_timeout_in_millis
  }

  dynamic "ssl_configuration" {
    for_each = var.enable_backend_ssl ? [1] : []

    content {
      verify_peer_certificate = var.verify_backend_peer_certificate
    }
  }
}

resource "oci_load_balancer_backend" "primary" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.primary.name
  ip_address       = var.backend_ip_address
  port             = var.primary_backend_port
}

resource "oci_load_balancer_backend" "alternate" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.alternate.name
  ip_address       = var.backend_ip_address
  port             = var.alternate_backend_port
}

resource "oci_load_balancer_hostname" "primary" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = var.primary_hostname_name
  hostname         = var.primary_hostname
}

resource "oci_load_balancer_hostname" "alternate" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = var.alternate_hostname_name
  hostname         = var.alternate_hostname
}

resource "oci_load_balancer_rule_set" "http_redirect" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = var.http_redirect_rule_set_name

  # OCI round-trips redirect rule items with computed/defaulted fields that
  # do not remain stable in Terraform state, which causes perpetual no-op diffs.
  lifecycle {
    ignore_changes = [items]
  }

  items {
    action        = "REDIRECT"
    description   = "Redirect HTTP traffic to HTTPS."
    response_code = 301

    conditions {
      attribute_name  = "PATH"
      attribute_value = "/"
      operator        = "PREFIX_MATCH"
    }

    redirect_uri {
      protocol = "HTTPS"
      port     = 443
      path     = "/{path}"
      query    = "{query}"
    }
  }
}

resource "oci_load_balancer_listener" "http" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.primary.name
  port                     = 80
  protocol                 = "HTTP"
  rule_set_names           = [oci_load_balancer_rule_set.http_redirect.name]
}

resource "oci_load_balancer_listener" "primary_https" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "https-${var.primary_hostname_name}"
  default_backend_set_name = oci_load_balancer_backend_set.primary.name
  hostname_names           = [oci_load_balancer_hostname.primary.name]
  port                     = 443
  protocol                 = "HTTP"

  lifecycle {
    ignore_changes = [ssl_configuration]
  }

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.this[0].certificate_name
    verify_peer_certificate = false
  }
}

resource "oci_load_balancer_listener" "alternate_https" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "https-${var.alternate_hostname_name}"
  default_backend_set_name = oci_load_balancer_backend_set.alternate.name
  hostname_names           = [oci_load_balancer_hostname.alternate.name]
  port                     = 443
  protocol                 = "HTTP"

  lifecycle {
    ignore_changes = [ssl_configuration]
  }

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.this[0].certificate_name
    verify_peer_certificate = false
  }
}
