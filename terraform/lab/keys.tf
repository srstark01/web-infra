resource "tls_private_key" "key" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}