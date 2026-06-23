terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 4.30"
      #configuration_aliases = [azurerm.acr]
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "746d02a8-8c56-46c0-82e7-7c736f5ca6c3"
  resource_provider_registrations = "none"
  features {}
}