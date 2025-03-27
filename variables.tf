variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region where the cluster will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the existing VNet where the AKS cluster will be deployed"
  type        = string
}

variable "nodes_subnet_id" {
  description = "The ID of the subnet where the AKS nodes will be deployed"
  type        = string
}

variable "api_server_subnet_id" {
  description = "The ID of the subnet where the AKS API server will be deployed"
  type        = string
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use for the AKS cluster"
  type        = string
  default     = "1.31"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "network_plugin" {
  description = "Network plugin to use for the cluster. Must be 'cilium' for Cilium CNI."
  type        = string
  default     = "cilium"
}

variable "network_policy" {
  description = "Network policy to use for the cluster. Must be 'cilium' for Cilium CNI."
  type        = string
  default     = "cilium"
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name       = string
    node_count = number
    vm_size    = string
  })
  default = {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }
} 