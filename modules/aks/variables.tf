variable "rg_name" {
    description = "Azure Resource Group Name"
    type = string
}
variable "env" {
  description = "Azure Environment"
}

#===== AKS VARIABLES =======#

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type = string
  default = null
}

#variable "ip_ranges" {
#  type = list(string)
#  description = "Authorized IP ranges"
#}

variable "location" {
  description = "AKS Name"
  type = string
}

variable "prefix" {
  type        = string
  default     = ""
  description = "(Optional) The prefix for the resources created"
}

variable "admin_username" {
  default     = "azureuser"
  description = " The username of the local administrator to be created on the Kubernetes cluster"
  type        = string
}

variable "agents_type" {
  description = "(Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets."
  type        = string
  default     = "VirtualMachineScaleSets"
}

variable "dns_prefix_private_cluster" {
  type        = string
  default     = null
  description = "(Optional) Specifies the DNS prefix to use with private clusters."
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region"
}

variable "private_cluster_enabled" {
  type        = bool
  default     = false
  description = "If true cluster API server will be exposed only on internal IP address and available only in cluster vnet."
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "(Optional) Either the ID of Private DNS Zone which should be delegated to this Cluster"
}

variable "role_based_access_control_enabled" {
  type        = bool
  default     = false
  description = "Enable Role Based Access Control."
  nullable    = false
}

variable "workload_identity_enabled" {
  type        = bool
  default     = false
  description = "Enable or Disable Workload Identity. Defaults to false."
}

variable "sku_tier" {
  type        = string
  default     = "Standard"
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are `Free`, `Standard` and `Premium`"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "The SKU Tier must be either `Free`, `Standard` or `Premium`."
  }
}

variable "admin_group_object_ids" {
  description = "Object ID of groups with admin access."
  type        = list(string)
  default     = null
}

variable "enable_role_based_access_control" {
  description = "(Optional) Enable Role Based Access Control."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  type        = bool
  default     = false
  description = "Enable or Disable the OIDC issuer URL. Defaults to false."
}

variable "identity_type" {
  type        = string
  default     = "UserAssigned"
  description = "(Optional) The type of identity used for the managed cluster. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, an `identity_ids` must be set as well."

  validation {
    condition     = var.identity_type == "SystemAssigned" || var.identity_type == "UserAssigned"
    error_message = "`identity_type`'s possible values are `SystemAssigned` and `UserAssigned`"
  }
}

variable "client_id" {
  type        = string
  default     = ""
  description = "(Optional) The Client ID (appId) for the Service Principal used for the AKS deployment"
}

variable "client_secret" {
  type        = string
  default     = ""
  description = "(Optional) The Client Secret (password) for the Service Principal used for the AKS deployment"
  sensitive   = true
}

variable "network_plugin" {
  type        = string
  default     = "azure"
  description = "Network plugin to use for networking."
  nullable    = false
}

variable "dns_service_ip" {
  type        = string
  default     = null
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)"
}

variable "network_data_plane" {
  type        = string
  default     = null
  description = "(Optional) Specifies the eBPF data plane used for building the Kubernetes network. Possible value is `cilium`. Changing this forces a new resource to be created."
}

variable "network_plugin_mode" {
  type        = string
  default     = null
  description = "(Optional) Specifies the network plugin mode used for building the Kubernetes network. Possible value is `overlay`. Changing this forces a new resource to be created."
}

variable "network_policy" {
  type        = string
  default     = null
  description = " (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
}

variable "outbound_type" {
  type        = string
  default     = "loadBalancer"
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
}

variable "pod_cidr" {
  type        = string
  default     = null
  description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet or network_plugin is set to azure and network_plugin_mode is set to overlay. Changing this forces a new resource to be created."
}

variable "vnet_id" {
  description = "VNTE ID"
}

variable "service_cidr" {
  type        = string
  default     = null
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
}

variable "agents_pool_name" {
  description = "The default Azure AKS agentpool (nodepool) name."
  type        = string
  default     = "nodepool"
}

variable "agents_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created."
}

variable "auto_scaling_enabled" {
  type        = bool
  default     = false
  description = "Enable node pool autoscaling"
}

variable "host_encryption_enabled" {
  type        = bool
  default     = false
  description = "Enable Host Encryption for default node pool."
}

variable "agents_max_count" {
  type        = number
  default     = null
  description = "Maximum number of nodes in a pool"
}

variable "agents_min_count" {
  type        = number
  default     = null
  description = "Minimum number of nodes in a pool"
}

variable "agents_max_pods" {
  type        = number
  default     = null
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
}

variable "agents_count" {
  type        = number
  default     = 2
  description = "The number of Node that should exist in the Node Pool. Please set `node_count` `null` while `auto_scaling_enabled` is `true` to avoid possible `node_count` changes."
}

variable "agents_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created."
  type        = map(string)
  default     = {}
}

variable "agents_tags" {
  description = "(Optional) A mapping of tags to assign to the Node Pool."
  type        = map(string)
  default = {
    role = "AKS"
    type = "cluster"
  }
}

#variable "node_public_ip_enabled" {
#  type        = bool
#  default     = false
#  description = "(Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false."
#}

variable "orchestrator_version" {
  type        = string
  default     = null
  description = "Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region"
}

variable "os_disk_size_gb" {
  type        = number
  default     = 50
  description = "Disk size of nodes in GBs."
}

variable "os_disk_type" {
  type        = string
  default     = "Managed"
  description = "The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. Changing this forces a new resource to be created."
  nullable    = false
}

variable "os_sku" {
  type        = string
  default     = null
  description = "(Optional) Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if OSType=Linux or `Windows2019` if OSType=Windows."
}

variable "availability_zones" {
  type        = list(string)
  default     = null
  description = "(Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created."
}

variable "vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default = {
    platform = "Azure"
    owner    = "BOA"
  }
}
variable "agents_pool_max_surge" {
  type        = string
  default     = "10%"
  description = "The maximum number or percentage of nodes which will be added to the Default Node Pool size during an upgrade."
}

variable "agents_pool_drain_timeout_in_minutes" {
  type        = number
  default     = null
  description = "(Optional) The amount of time in minutes to wait on eviction of pods and graceful termination per node. This eviction wait time honors waiting on pod disruption budgets. If this time is exceeded, the upgrade fails. Unsetting this after configuring it will force a new resource to be created."
}

variable "agents_pool_node_soak_duration_in_minutes" {
  type        = number
  default     = 0
  description = "(Optional) The amount of time in minutes to wait after draining a node and before reimaging and moving on to next node. Defaults to 0."
}

variable "agents_pool_undrainable_node_behavior" {
  type        = string
  default     = null
  description = "(Optional) The behavior of nodes that cannot be drained during an upgrade. Valid values are `Cordon` and `Schedule`. Unsetting this after configuring it will force a new resource to be created."

  validation {
    condition     = var.agents_pool_undrainable_node_behavior == null ? true : contains(["Cordon", "Schedule"], var.agents_pool_undrainable_node_behavior)
    error_message = "`agents_pool_undrainable_node_behavior` must be `null`, `\"Cordon\"`, or `\"Schedule\"`."
  }
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}

variable "cluster_log_analytics_workspace_name" {
  description = "(Optional) The name of the Analytics workspace"
  type        = string
  default     = null
}

variable "law_sku" {
  description = "(Optional) The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "(Optional) The retention period for the logs in days"
  type        = number
  default     = 30
}

variable "acr_id" {
  description   = "Container registry ID"
  type          = string
}

variable "aks_private_dns_zone" {
  description       = "AKS Private zone DNS"
  default           = "privatelink.northeurope.azmk8s.io"
}

variable "maintenance_window_node_os" {
  type = object({
    day_of_month = optional(number)
    day_of_week  = optional(string)
    duration     = optional(number)
    frequency    = string
    interval     = number
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(set(object({
      end   = string
      start = string
    })))
  })
  default     = null
}

variable "node_os_channel_upgrade" {
  type        = string
  default     = null
  description = " (Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`."
}

variable "node_pools" {
  type = map(object({
    name                = string
    vm_size             = string
    node_count          = number
    min_count           = optional(number)
    max_count           = optional(number)
    zones               = optional(list(string))
    labels              = optional(map(string))
    taints              = optional(list(string))
    max_pod             = number
    os_disk_size_gb     = number
    os_disk_type        = string
    ultra_ssd_enabled   = bool
    deploy_temporary_pool= bool
    #node_public_ip_enabled= bool
  }))
}

variable "temporary_name_for_rotation" {
  description = "The temporary node pool"
  default = "temppool"
}