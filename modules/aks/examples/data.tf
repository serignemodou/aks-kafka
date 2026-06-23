#####################################################################
# Retrieve current config
#####################################################################
data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

data "azurerm_subnet" "subnet_dev" {
  virtual_network_name = "VNET-KUB-DEV"
  name                 = "default"
  resource_group_name  = "RG-KUB-DEV"
}

data "azurerm_virtual_network" "vnet_dev" {
  resource_group_name = "RG-KUB-DEV"
  name                = "VNET-KUB-DEV"
}

data "azuread_group" "admin-group-dev" {
  display_name = "GRP_KUB_DEV"
  security_enabled = true
}