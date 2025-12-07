data "azurerm_resource_group" "aks" {
  name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "aks_subnet_contributor" {
  scope                = var.nodes_subnet_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "aks_identity_operator" {
  scope                = azurerm_user_assigned_identity.aks.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azapi_resource" "aks" {
  type      = "Microsoft.ContainerService/managedClusters@2025-07-01"
  name      = var.cluster_name
  parent_id = data.azurerm_resource_group.aks.id
  location  = var.location
  body = {
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        "${azurerm_user_assigned_identity.aks.id}" = {}
      }
    }
    sku = {
      name = "Base"
      tier = "Free"
    }
    properties = {
      kubernetesVersion   = var.kubernetes_version
      dnsPrefix           = var.dns_prefix
      enableRBAC        = true
      nodeResourceGroup = "${var.cluster_name}-node-rg"
      agentPoolProfiles : [
        {
          name                = var.default_node_pool.name
          count               = var.default_node_pool.node_count
          vmSize              = "Standard_D2_v5"
          vnetSubnetID        = var.nodes_subnet_id
          availabilityZones   = ["1", "2", "3"]
          enableAutoScaling   = true
          minCount            = 3
          maxCount            = 10
          maxPods             = 110
          osDiskSizeGB        = 64
          osDiskType          = "Managed"
          osType              = "Linux"
          mode                = "System"
          scaleSetPriority    = "Regular"
          spotMaxPrice        = -1
          tags                = var.tags
          upgradeSettings = {
            maxSurge = "33%"
          }
          nodeLabels = {
            "node.kubernetes.io/role" = "system"
            environment               = "production"
          }
          nodeTaints = [
            "CriticalAddonsOnly=true:PreferNoSchedule"
          ]
          orchestratorVersion = var.kubernetes_version
          securityProfile = {
            enableSecureBoot = true
            enableVTPM = true
          }
        }
      ]
      autoScalerProfile = {
        "balance-similar-node-groups"    = "true"
        "expander"                       = "least-waste"
        "max-empty-bulk-delete"          = "10"
        "max-graceful-termination-sec"   = "600"
        "max-node-provision-time"        = "15m"
        "max-total-unready-percentage"   = "45"
        "new-pod-scale-up-delay"         = "0s"
        "ok-total-unready-count"         = "3"
        "scale-down-delay-after-add"     = "10m"
        "scale-down-delay-after-delete"  = "10s"
        "scale-down-delay-after-failure" = "3m"
        "scale-down-unneeded-time"       = "10m"
        "skip-nodes-with-local-storage"  = "true"
        "skip-nodes-with-system-pods"    = "true"
      }
      apiServerAccessProfile = {
        enableVnetIntegration          = true
        subnetId                       = var.api_server_subnet_id
        disableRunCommand              = false
        enablePrivateCluster           = true
        enablePrivateClusterPublicFQDN = true
      }
      autoUpgradeProfile = {
        upgradeChannel = "stable"
      }
      networkProfile = {
        networkPlugin     = "azure"
        networkPluginMode = "overlay"
        networkDataplane  = "cilium"
        podCidr           = "172.16.0.0/20"
        serviceCidr       = "172.16.16.0/24"
        dnsServiceIP      = "172.16.16.10"
        advancedNetworking = {
          enabled = true
          observability = {
            enabled = true
          }
          security = {
            enabled = false
          }
        }
      }
      oidcIssuerProfile = {
        enabled = true
      }
      publicNetworkAccess = "Disabled"
      securityProfile = {
        workloadIdentity = {
          enabled = true
        }
        imageCleaner = {
          enabled       = true
          intervalHours = 24
        }
      }
    }
    tags = var.tags
  }
}

resource "azapi_resource_action" "aks_kubeconfig" {
  type                   = "Microsoft.ContainerService/managedClusters@2025-07-01"
  resource_id            = azapi_resource.aks.id
  action                 = "listClusterAdminCredential"
  response_export_values = ["*"]
} 