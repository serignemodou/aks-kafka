output "container_registry_admin_username" {
  value = var.admin_enabled == true ? azurerm_container_registry.acr[0].admin_username : null
  description = "The username associated with container registry admin accoun"
}

output "container_registry_id" {
  value = azurerm_container_registry.acr[0].id
  description = "Container Registry ID"
}

output "container_registry_identity_principal_id" {
  value = azurerm_container_registry.acr[0].identity[0].principal_id
  description = "The principal ID for service principal with the Managed Service Identity of this Container Registry"
}

output "container_registry_private_endpoint" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.pe_acr[0].id : null
  description = "The ID of the Azure Container Registry Private Endpoint"
}

output "container_registry_private_dns_zone_domain" {
  value       =  var.enable_private_endpoint ? azurerm_private_dns_zone.dnszone1[0].name : null
  description = "DNS zone name of Azure Container Registry Private endpoints dns name records"
}