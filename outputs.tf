# outputs.tf

##################################################
# Outputs for instances
##################################################

output "mgmt001-public-IP" {
  value = oci_core_instance.mgmt001.public_ip
}

output "mgmt001-private-IP" {
  value = oci_core_instance.mgmt001.private_ip
}

output "app001-private-IP" {
  value = oci_core_instance.app001.private_ip
}

output "app002-private-IP" {
  value = oci_core_instance.app002.private_ip
}

##################################################
# Outputs for load balancers
##################################################

output "load-balancer-public-IP" {
   value = oci_load_balancer_load_balancer.portfolio-load-balancer.ip_address_details[0].ip_address
}

##################################################
# Outputs image info
##################################################

