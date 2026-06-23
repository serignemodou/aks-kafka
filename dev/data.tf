#####################################################################
# Retrieve current config
#####################################################################
data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}


#####################################################################
# Retrieve AD groups of the Kub DEV
#####################################################################
data "azuread_group" "admin-group-dev" {
  display_name = "GRP_KUB_DEV"
}

#####################################################################
# Retrieve VnetID of the Kub DEV
#####################################################################
data "azurerm_virtual_network" "vnet_dev" {
  resource_group_name = "RG-KUB-DEV"
  name                = "VNET-KUB-DEV"
}

#####################################################################
# Retrieve SubnetID of the Kub DEV
#####################################################################
data "azurerm_subnet" "subnet_dev" {
  virtual_network_name = "VNET-KUB-DEV"
  name                 = "default"
  resource_group_name  = "RG-KUB-DEV"
}