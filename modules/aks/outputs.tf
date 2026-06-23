output "aks_id" {
  description = "AKS Resource ID"
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  description = "AKS Resource Name"
  value = azurerm_kubernetes_cluster.aks.name
}

output "kubelet_identity" {
  description = "Managed Identity used by AKS Agents"
  value = ""
}

