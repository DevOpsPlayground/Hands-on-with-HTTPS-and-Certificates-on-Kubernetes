output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "resource_group_location" {
  value = azurerm_resource_group.default.location
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}

output "host" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.host
}

output "client_key" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.default.kube_config_raw
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.password
}

output "sp_client_id" {
  value = azuread_service_principal.sp.application_id
}

output "sp_object_id" {
  value = azuread_service_principal.sp.object_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "az_user_client_id" {
  value = data.azurerm_client_config.current.client_id
}