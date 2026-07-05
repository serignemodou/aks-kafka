#####################################################################
# Retrieve current config
#####################################################################
data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

#####################################################################
# Retrieve AD groups of the Kub PROD
#####################################################################
data "azuread_group" "admin-group-prod" {
  display_name = "GRP_KUB_PROD"
}

#####################################################################
# Retrieve VnetID of the Kub PROD
#####################################################################
data "azurerm_virtual_network" "vnet_prod" {
  resource_group_name = "RG-KUB-PROD"
  name                = "VNET-KUB-PROD-NEW"
}

#####################################################################
# Retrieve SubnetID of the Kub PROD
#####################################################################
data "azurerm_subnet" "subnet_prod" {
  virtual_network_name = "VNET-KUB-PROD-NEW"
  name                 = "default"
  resource_group_name  = "RG-KUB-PROD"
}