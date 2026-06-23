module "aks_exemple" {
  source                            = "../"
  acr_id                            = "/subscriptions/746d02a8-8c56-46c0-82e7-7c736f5ca6c3/resourceGroups/RG-KUB-DEV/providers/Microsoft.ContainerRegistry/registries/kubacrdev"
  rg_name                           = "RG-KUB-DEV"
  env                               = "dev"
  location                          = "North Europe"
  prefix                            = "kub"
  kubernetes_version                = "1.33.5"
  private_cluster_enabled           = true
  role_based_access_control_enabled = true
  sku_tier                          = "Standard"
  dns_service_ip                    = "198.10.0.10"

  # AKS Linux Profil
  admin_username                    = "azureuser"

  #aks identity
  oidc_issuer_enabled               = true
  admin_group_object_ids            = [data.azuread_group.admin-group-dev.id]
  enable_role_based_access_control  = true
  workload_identity_enabled         = true

  # AKS default nodepool
  agents_pool_name                  = "defaultpool"
  orchestrator_version              = "1.33.5"
  agents_count                      = 2
  agents_size                       = "Standard_D4s_v5"
  os_disk_size_gb                   = 50
  vnet_subnet_id                    = data.azurerm_subnet.subnet_dev.id
  auto_scaling_enabled              = false
  agents_max_count                  = 2
  agents_min_count                  = 1
  availability_zones                = [ "1", "2", "3" ]
  agents_type                       = "VirtualMachineScaleSets"
  agents_max_pods                   = 110
  host_encryption_enabled           = false #Subscription does not enable EncryptionAtHost."
  os_disk_type                      = "Managed"
  os_sku                            = "Ubuntu"
  #ip_ranges                         = [ "212.32.90.34" ]
  agents_labels = {
    "workload"      = "system",
    "environment"   = "dev"
    "role"          = "system"
  }
  agents_tags = {
    "nodepool"      = "default"
  }

  # AKS Upgrade 
  agents_pool_max_surge                     = "50%"
  agents_pool_drain_timeout_in_minutes      = 30
  agents_pool_node_soak_duration_in_minutes = 5
  agents_pool_undrainable_node_behavior     = "Schedule"

  node_os_channel_upgrade           = "NodeImage" 

  maintenance_window_node_os        = {
    frequency       = "Weekly"
    interval        = 1
    day_of_week     = "Sunday"
    start_time      = "00:00"
    duration        = 5
  }

  # aks workspace
  enable_log_analytics_workspace = true

  vnet_id = data.azurerm_virtual_network.vnet_dev.id

  # aks network
  network_plugin        = "azure"
  network_plugin_mode   = "overlay"
  #network_policy        = ""
  outbound_type         =  "loadBalancer" #"userDefinedRouting"
  pod_cidr              = "188.10.0.0/16"
  service_cidr          = "198.10.0.0/16"

  node_pools = {
    apppool = {
        vm_size                 = "Standard_D8s_v5"
        name                    = "app"
        node_count              = 4
        max_count               = 5
        min_count               = 2
        max_pod                 = 110
        deploy_temporary_pool   = false
        os_disk_size_gb         = 50
        os_disk_type            = "Managed"
        ultra_ssd_enabled       = false
        zones                   = ["1", "2", "3"]
        taints                  = []
        labels = {
          "type"        = "app",
          "environment" = "dev"
          "role"        = "app"
        }
    }
  }
}