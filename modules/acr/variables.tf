variable "rg_name" {
    description = "Azure Resource Group Name"
    type = string
}
variable "env" {
  description = "Azure Environment"
}

#===== ACR VARIABLES =======#

variable "location" {
  description = "AKS Name"
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default = {
    platform = "Azure"
    owner    = "BOA"
  }
}

variable "enable" {
  type        = bool
  default     = true
  description = "Flag to control acr creation."
}

variable "admin_enabled" {
  type        = bool
  default     = true
  description = "To enable of disable admin access"
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "To denied public access "
}

variable "container_registry_config" {
  type = object({
    name                      = string
    sku                       = optional(string)
    quarantine_policy_enabled = optional(bool)
    zone_redundancy_enabled   = optional(bool)
  })
  description = "Manages an Azure Container Registry"
}

variable "vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

#azure_service_bypass
variable "azure_services_bypass" {
  type        = string
  default     = "AzureServices"
  description = "Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are None and AzureServices. Defaults to AzureServices"
}

variable "georeplications" {
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool)
  }))
  default     = []
  description = "A list of Azure locations where the container registry should be geo-replicated"
}

variable "network_rule_set" {
  type = object({
    default_action = optional(string)
    ip_rule = optional(list(object({
      ip_range = string
      action = string
    })))
    virtual_network = optional(list(object({
      subnet_id = string
    })))
  })
  default     = null
  description = "Manage network rules for Azure Container Registries"
}

variable "retention_policy_in_days" {
  type        = number
  default     = 5
  description = "Set a retention policy for untagged manifests"
}

variable "enable_content_trust" {
  type        = bool
  default     = true
  description = "Boolean value to enable or disable Content trust in Azure Container Registry"
}

variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Manages a Private Endpoint to Azure Container Registry"
}

variable "private_dns_name" {
  type    = string
  default = "privatelink.azurecr.io"
}