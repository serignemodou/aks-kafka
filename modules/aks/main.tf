# AKS User Managed Identity
resource "azurerm_user_assigned_identity" "aks_uia" {
  name                = "kub-uia-${var.env}"
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags 
}

# AKS Logs Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks_law" {
  count                 = var.enable_log_analytics_workspace ? 1 : 0
  name                  = var.cluster_log_analytics_workspace_name == null ? "law-${var.env}" : var.cluster_log_analytics_workspace_name
  location              = var.location
  resource_group_name   = var.rg_name
  sku                   = var.law_sku
  retention_in_days     = var.log_retention_in_days
  tags                  = var.tags
}

# AKS Private Zone DNS
resource "azurerm_private_dns_zone" "prv-dns-zone" {
  resource_group_name = var.rg_name
  name                = "privatelink.northeurope.azmk8s.io"
  tags                = var.tags
}

# AKS Private zone DNS link
resource "azurerm_private_dns_zone_virtual_network_link" "aks_dns_link" {
  name                  = "aks-dns-link-${var.env}"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.prv-dns-zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

# AKS SSH Key
resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
  rsa_bits    =  4096
}

# AKS Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                              = var.cluster_name == null ? "kub-${var.env}" : var.cluster_name
  location                          = var.location
  resource_group_name               = var.rg_name
  dns_prefix                        = var.prefix
  dns_prefix_private_cluster        = var.dns_prefix_private_cluster
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = var.private_cluster_enabled
  private_dns_zone_id               = azurerm_private_dns_zone.prv-dns-zone.id
  role_based_access_control_enabled = var.role_based_access_control_enabled
  workload_identity_enabled         = var.workload_identity_enabled
  sku_tier                          = var.sku_tier
  oidc_issuer_enabled               = var.oidc_issuer_enabled
  node_os_upgrade_channel           = var.node_os_channel_upgrade
  #api_server_access_profile {
  #  authorized_ip_ranges = var.ip_ranges
  #}

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data     = tls_private_key.ssh.public_key_openssh
    }
  }

  #bootstrap_profile {
  #  container_registry_id = var.acr_id
  #}
  
  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os == null ? [] : [var.maintenance_window_node_os]
    content {
      duration      = maintenance_window_node_os.value.duration
      frequency     = maintenance_window_node_os.value.frequency
      interval      = maintenance_window_node_os.value.interval
      day_of_month  = maintenance_window_node_os.value.day_of_month
      day_of_week   = maintenance_window_node_os.value.day_of_week
      start_date    = maintenance_window_node_os.value.start_date
      start_time    = maintenance_window_node_os.value.start_time
      utc_offset    = maintenance_window_node_os.value.utc_offset
      week_index    = maintenance_window_node_os.value.week_index
      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed == null ? [] : [var.maintenance_window_node_os.value.not_allowed]
        content {
          end = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "default_node_pool" {
    for_each = var.agents_pool_name == "defaultpool" ? ["default_node_pool"] : []
    content {
      orchestrator_version    = var.orchestrator_version
      name                    = var.agents_pool_name
      node_count              = var.agents_count
      vm_size                 = var.agents_size
      os_disk_size_gb         = var.os_disk_size_gb
      vnet_subnet_id          = var.vnet_subnet_id
      auto_scaling_enabled    = var.auto_scaling_enabled
      max_count               = var.auto_scaling_enabled == true ? var.agents_max_count : null
      min_count               = var.auto_scaling_enabled == true ? var.agents_min_count : null
      #node_public_ip_enabled  = var.node_public_ip_enabled
      zones                   = var.availability_zones
      node_labels             = var.agents_labels
      type                    = var.agents_type
      tags                    = merge(var.tags, var.agents_tags)
      max_pods                = var.agents_max_pods
      host_encryption_enabled = var.host_encryption_enabled
      os_disk_type            = var.os_disk_type
      os_sku                  = var.os_sku

      upgrade_settings {
          max_surge                     = var.agents_pool_max_surge
          drain_timeout_in_minutes      = var.agents_pool_drain_timeout_in_minutes
          node_soak_duration_in_minutes = var.agents_pool_node_soak_duration_in_minutes
      }
    }
  }

  identity {
    type         = var.identity_type
    identity_ids =[azurerm_user_assigned_identity.aks_uia.id]
  }

  oms_agent {
    log_analytics_workspace_id = var.enable_log_analytics_workspace ? azurerm_log_analytics_workspace.aks_law[0].id : null
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_role_based_access_control && var.oidc_issuer_enabled ? [1] : []
    content {
      admin_group_object_ids  = var.admin_group_object_ids
      azure_rbac_enabled      = var.enable_role_based_access_control
      #tenant_id = var.tenant_id
    }
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_policy      = var.network_policy
    dns_service_ip      = var.dns_service_ip
    network_data_plane  = var.network_data_plane
    network_plugin_mode = var.network_plugin_mode
    outbound_type       = var.outbound_type
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
  }
  
  tags = var.tags

  depends_on = [ 
    azurerm_role_assignment.aks_dns_role, 
    azurerm_role_assignment.aks_network_contributor 
  ]

}

# AKS ACR Role assignment 
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope               = var.acr_id
  role_definition_name  = "AcrPull"
  principal_id        = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# AKS Network role assignment
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                 = var.vnet_subnet_id
  role_definition_name    = "Network Contributor"
  principal_id          = azurerm_user_assigned_identity.aks_uia.principal_id #azurerm_user_assigned_identity.aks_uia.principal_id
}

# AKS Private DNS Zone Contributor
resource "azurerm_role_assignment" "aks_dns_role" {
  scope                = azurerm_private_dns_zone.prv-dns-zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_uia.principal_id #azurerm_kubernetes_cluster.aks.identity[0].principal_id 
}


resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  name                    = each.value.name
  kubernetes_cluster_id   = azurerm_kubernetes_cluster.aks.id
  vm_size                 = each.value.vm_size
  node_count              = each.value.node_count
  orchestrator_version    = var.kubernetes_version
  zones                   = try(each.value.zones, var.availability_zones)
  node_labels             = try(each.value.labels, var.agents_labels)
  node_taints             = each.value.taints
  #node_public_ip_enabled  = each.value.node_public_ip_enabled
  max_pods                = each.value.max_pod
  host_encryption_enabled = var.host_encryption_enabled
  os_disk_size_gb         = each.value.os_disk_size_gb
  os_disk_type            = each.value.os_disk_type
  os_type                 = "Linux"
  vnet_subnet_id          = var.vnet_subnet_id

  upgrade_settings {
    max_surge                     = var.agents_pool_max_surge
    drain_timeout_in_minutes      = var.agents_pool_drain_timeout_in_minutes
    node_soak_duration_in_minutes = var.agents_pool_node_soak_duration_in_minutes
    
  }
  auto_scaling_enabled = var.auto_scaling_enabled
  min_count            = var.auto_scaling_enabled ? try(each.value.min_count, null) : null
  max_count            = var.auto_scaling_enabled ? try(each.value.max_count, null) : null

  tags = var.tags
}