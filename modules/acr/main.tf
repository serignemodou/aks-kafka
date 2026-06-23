resource "azurerm_user_assigned_identity" "acr-uia" {
  name                = "kub-acr-uia-${var.env}"
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags 
}

resource "azurerm_container_registry" "acr" {
  count                         = var.enable ? 1 : 0
  name                          = format("%s", var.container_registry_config.name)
  resource_group_name           = var.rg_name
  location                      = var.location
  admin_enabled                 = var.admin_enabled
  sku                           = var.container_registry_config.sku
  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.container_registry_config.quarantine_policy_enabled
  zone_redundancy_enabled       = var.container_registry_config.zone_redundancy_enabled
  network_rule_bypass_option    = var.azure_services_bypass

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      tags                      = var.tags
    }
  }

  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = lookup(network_rule_set.value, "default_action", "Allow")
      dynamic "ip_rule"{
        for_each = network_rule_set.value.ip_rule
        content {
          action    = "Allow"
          ip_range  = ip_rule.value.ip_range
        }
      }
    }
  }
  
  trust_policy_enabled = var.container_registry_config.sku == "Premium" ? var.enable_content_trust : false
  retention_policy_in_days =  var.retention_policy_in_days != null && var.container_registry_config.sku == "Premium" ? var.retention_policy_in_days : null

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr-uia.id]
  }
}

resource "azurerm_private_endpoint" "pe_acr" {
  count                   = var.enable && var.enable_private_endpoint ? 1 : 0
  resource_group_name     = var.rg_name
  location                = var.location
  name                    = "pe-acr-${var.env}"
  subnet_id               = var.vnet_subnet_id
  private_dns_zone_group {
    name                  = "acr-dns-zone-group-${var.env}"
    private_dns_zone_ids  = [ azurerm_private_dns_zone.dnszone1[0].id ]
  }
  private_service_connection {
    name                            = "acr-psc-${var.env}"
    is_manual_connection            = false
    private_connection_resource_id  = azurerm_container_registry.acr[0].id
    subresource_names               = [ "registry" ]
  }
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_zone" "dnszone1" {
  count                 = var.enable && var.enable_private_endpoint ? 1 : 0
  resource_group_name   = var.rg_name
  name                  = var.private_dns_name
  tags                  = var.tags
}