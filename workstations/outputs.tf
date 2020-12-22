output "kubernetes_namespace_names" {
  value = [for ns in kubernetes_namespace.ns : ns.metadata[0].name]
}

output "azure_vm_public_ips" {
  value = [for pub_ip in azurerm_public_ip.public : pub_ip.ip_address]
}