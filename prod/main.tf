# ACR Module
module "acr" {
  source                        = "../modules/acr"
  env                           = "prod"
  admin_enabled                 = true
  rg_name                       = "RG-KUB-PROD"
  location                      = "North Europe"
  enable_content_trust          = false
  public_network_access_enabled = true
  private_dns_name              = "privatelink.azurecr.io"
  vnet_subnet_id                =  data.azurerm_subnet.subnet_prod.id
  container_registry_config     = {
    name                      = "kubacrprod" 
    sku                       = "Premium"
    quarantine_policy_enabled = false
    zone_redundancy_enabled   = false
  }
  network_rule_set              = {
    default_action = "Allow" # Change to "Deny" and uncomment when we have BAO CIDR
    ip_rule = [ {
      action = "Allow",
      ip_range = "192.16.0.0/16"
    } ]
  }
  tags                          = {
    "environment" = "prod"
    "company"     = "boa" 
  }
}

# AKS Module
module "aks" {
  source                            = "../modules/aks"
  acr_id                            = module.acr.container_registry_id
  rg_name                           = "RG-KUB-PROD"
  env                               = "prod"
  location                          = "North Europe"
  prefix                            = "kub"
  kubernetes_version                = "1.33.5"
  private_cluster_enabled           = true
  role_based_access_control_enabled = true
  sku_tier                          = "Standard"
  dns_service_ip                    = "198.12.0.10"

  # AKS Linux Profil
  admin_username                    = "azureuser"

  #aks identity
  oidc_issuer_enabled               = true
  admin_group_object_ids            = [data.azuread_group.admin-group-prod.id]
  enable_role_based_access_control  = true
  workload_identity_enabled         = true

  # AKS default nodepool
  agents_pool_name                  = "defaultpool"
  orchestrator_version              = "1.33.5"
  agents_count                      = 2
  agents_size                       = "Standard_D4s_v5"
  os_disk_size_gb                   = 50
  vnet_subnet_id                    = data.azurerm_subnet.subnet_prod.id
  auto_scaling_enabled              = true
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
    "environment"   = "prod"
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

  vnet_id = data.azurerm_virtual_network.vnet_prod.id

  # aks network
  network_plugin        = "azure"
  network_plugin_mode   = "overlay"
  outbound_type         =  "loadBalancer" #"userDefinedRouting"
  pod_cidr              = "188.12.0.0/16"
  service_cidr          = "198.12.0.0/16"

  node_pools = {
    apppool = {
        vm_size                 = "Standard_D8s_v5"
        name                    = "app"
        node_count              = 7
        max_count               = 10
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
          "environment" = "prod"
          "role"        = "app"
        }
    }
  }
  
}