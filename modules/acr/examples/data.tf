data "azurerm_subnet" "subnet_dev" {
  virtual_network_name = "VNET-KUB-DEV"
  name                 = "default"
  resource_group_name  = "RG-KUB-DEV"
}