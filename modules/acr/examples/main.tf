module "acr-example" {
  source                        = "../"
  env                           = "dev"
  admin_enabled                 = true
  rg_name                       = "RG-KUB-DEV"
  location                      = "North Europe"
  enable_content_trust          = false
  public_network_access_enabled = true
  private_dns_name              = "privatelink.azurecr.io"
  vnet_subnet_id              =  data.azurerm_subnet.subnet_dev.id
  container_registry_config     = {
    name                      = "kubacrdev" 
    sku                       = "Premium"
    quarantine_policy_enabled = false
    zone_redundancy_enabled   = false
  }
  network_rule_set              = {
    default_action = "Deny" # Change to "Deny" and uncomment when we have BAO CIDR
    ip_rule = [
        {
          action = "Allow"
          ip_range = "212.32.90.34" # Change to boa company cidr
        }
    ]
  }
  tags                          = {
    "environment" = "Dev"
    "company"     = "boa" 
  }
}