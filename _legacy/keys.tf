resource "tls_private_key" "mgmt001_key" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

