output "kubernetes_namespace_names" {
  value = [for ns in kubernetes_namespace.ns : ns.metadata[0].name]
}

output "azure_vm_public_ips" {
  value = [for pub_ip in azurerm_public_ip.public : pub_ip.ip_address]
}

output "kubernetes_sa_secret_name" {
  # value = kubernetes_service_account.sa.secret[0].name
  value = [for sa in kubernetes_service_account.sa : sa.default_secret_name ]
}

# output "kubernetes_secret_ca_crt" {
#   # value = kubernetes_service_account.sa.secret[0].name
#   value = [for secret in data.kubernetes_secret.secret : secret.data["ca.crt"] ]
# }

# output "kubernetes_secret_token" {
#   # value = kubernetes_service_account.sa.secret[0].name
#   value = [for secret in data.kubernetes_secret.secret : secret.data["token"] ]
# }

output "kubernetes_secret_ca_crt" {
  # value = kubernetes_service_account.sa.secret[0].name
  value = [for secret in data.kubernetes_secret.secret : secret.data ]
}