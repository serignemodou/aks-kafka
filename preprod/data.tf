#####################################################################
# Retrieve current config
#####################################################################
data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

#####################################################################
# Retrieve AD groups of the Kub PREPROD
#####################################################################
data "azuread_group" "admin-group-preprod" {
  display_name = "GRP_KUB_PREPROD"
}

#####################################################################
# Retrieve VnetID of the Kub PREPROD
#####################################################################
data "azurerm_virtual_network" "vnet_preprod" {
  resource_group_name = "RG-KUB-PREPROD"
  name                = "VNET-KUB-PRPEPROD"
}

#####################################################################
# Retrieve SubnetID of the Kub PREPROD
#####################################################################
data "azurerm_subnet" "subnet_preprod" {
  virtual_network_name = "VNET-KUB-PRPEPROD"
  name                 = "default"
  resource_group_name  = "RG-KUB-PREPROD"
}