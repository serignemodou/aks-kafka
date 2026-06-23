#####################################################################
# Retrieve current config
#####################################################################
data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

#####################################################################
# Retrieve AD groups
#####################################################################

data "azuread_group" "admin-group-dev" {
  display_name = "GRP_KUB_DEV"
  security_enabled = true
}

data "azuread_group" "admin-group-preprod" {
  display_name = "GRP_KUB_PREPROD"
  security_enabled = true
}

data "azuread_group" "admin-group-prod" {
  display_name = "GRP_KUB_PROD"
  security_enabled = true
}

#####################################################################
# Retrieve VnetID of the Kub DEV - PREPROD - PROD
#####################################################################

data "azurerm_virtual_network" "vnet_dev" {
  resource_group_name = "RG-KUB-DEV"
  name                = "VNET-KUB-DEV"
}

data "azurerm_virtual_network" "vnet_preprod" {
  resource_group_name = "RG-KUB-PREPROD"
  name                = "VNET-KUB-PRPEPROD"
}

data "azurerm_virtual_network" "vnet_prod" {
  resource_group_name = "RG-KUB-PROD"
  name                = "VNET-KUB-PROD"
}

#####################################################################
# Retrieve SubnetID of the Kub DEV - PREPROD - PROD
#####################################################################

data "azurerm_subnet" "kub-vnet-dev" {
  virtual_network_name = "VNET-KUB-DEV"
  name                 = "default"
  resource_group_name  = "RG-KUB-DEV"
}

data "azurerm_subnet" "kub-vnet-preprod" {
  virtual_network_name = "VNET-KUB-PRPEPROD"
  name                 = "default"
  resource_group_name  = "RG-KUB-PREPROD"
}

data "azurerm_subnet" "kub-vnet-prod" {
  virtual_network_name = "VNET-KUB-PROD"
  name                 = "default"
  resource_group_name  = "RG-KUB-PROD"
}