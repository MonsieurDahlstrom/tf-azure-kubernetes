# Azure Kubernetes Service (AKS) Module

This Terraform module deploys a production-ready Azure Kubernetes Service (AKS) cluster with advanced networking and security features. It leverages the Azure API to configure the latest capabilities and create a secure, scalable Kubernetes environment.

## Features

- Deploys an AKS cluster with private API server using VNet integration
- Configures Cilium for advanced networking features
- Implements workload identity for secure authentication
- Uses overlay networking mode for enhanced pod-to-pod communication
- Implements auto-scaling at both cluster and node pool levels
- Configures system node pools with taints for system workloads
- Provides managed auto-upgrade channels
- Sets up RBAC with Azure AD integration
- Enables Advanced Container Networking Services for enhanced observability and security

## Prerequisites

- Azure subscription with appropriate permissions
  - Your subscription must be enabled for Advanced Container Networking Services (ACNS)
    - [Learn more about Advanced Container Networking Services](https://learn.microsoft.com/en-us/azure/aks/advanced-container-networking-services-overview)
  - Your subscription must be enabled for AKS VNet integration (apiServerVnetIntegration feature)
    - [Register the EnableAPIServerVnetIntegrationPreview feature flag](https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration#register-the-enableapiserververnetintegrationpreview-feature-flag)
  - Access to Azure API version 2024-10-02-preview for AKS
- Virtual Network with subnets for nodes and API server
- Terraform 1.6 or later
- Azure CLI (for local development)

## Usage

### Basic Usage

```hcl
module "aks" {
  source = "path/to/tf-azure-kubernetes"

  resource_group_name  = "my-aks-rg"
  location             = "westeurope"
  cluster_name         = "prod-aks"
  dns_prefix           = "prod-aks"
  
  vnet_id              = "/subscriptions/.../virtualNetworks/my-vnet"
  nodes_subnet_id      = "/subscriptions/.../subnets/aks-nodes"
  api_server_subnet_id = "/subscriptions/.../subnets/aks-api"
  
  default_node_pool = {
    name       = "system"
    node_count = 3
    vm_size    = "Standard_D2_v5"
  }

  tags = {
    Environment = "Production"
  }
}
```

### Advanced Usage with Custom Settings

```hcl
module "aks" {
  source = "path/to/tf-azure-kubernetes"

  resource_group_name  = "my-aks-rg"
  location             = "westeurope"
  cluster_name         = "prod-aks"
  kubernetes_version   = "1.32"
  dns_prefix           = "prod-aks"
  
  vnet_id              = "/subscriptions/.../virtualNetworks/my-vnet"
  nodes_subnet_id      = "/subscriptions/.../subnets/aks-nodes"
  api_server_subnet_id = "/subscriptions/.../subnets/aks-api"
  
  network_plugin = "cilium"
  network_policy = "cilium"
  
  default_node_pool = {
    name       = "system"
    node_count = 5
    vm_size    = "Standard_D4_v5"
  }
  
  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| resource_group_name | Name of the Azure resource group | string | yes | - |
| location | Azure region to deploy the cluster | string | yes | - |
| cluster_name | Name of the AKS cluster | string | yes | - |
| kubernetes_version | Kubernetes version to use | string | no | "1.31" |
| dns_prefix | DNS prefix for the cluster | string | yes | - |
| vnet_id | ID of the VNet for AKS integration | string | yes | - |
| nodes_subnet_id | ID of the subnet for AKS nodes | string | yes | - |
| api_server_subnet_id | ID of the subnet for AKS API server | string | yes | - |
| network_plugin | Network plugin to use for the cluster | string | no | "cilium" |
| network_policy | Network policy to use for the cluster | string | no | "cilium" |
| default_node_pool | Configuration for the default node pool | object | no | See below |
| tags | Additional tags to apply to all resources | map(string) | no | {} |

### Default Node Pool Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | Name of the node pool | string | yes | "default" |
| node_count | Number of nodes in the pool | number | yes | 1 |
| vm_size | Size of the VMs in the node pool | string | no | "Standard_D2_v2" |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the AKS cluster |
| cluster_name | Name of the AKS cluster |
| kube_config | Kubernetes configuration for the cluster (sensitive) |
| cluster_endpoint | The Kubernetes cluster server endpoint |
| cluster_identity | The identity used by the AKS cluster |

## Security Considerations

- Private cluster with VNet integration for API server
- User-assigned managed identity for secure Azure resource access
- Workload identity for secure pod authentication
- Cilium networking with enhanced observability
- Auto-scaling for resource optimization
- Automatic image cleaning for reduced attack surface
- System node pools with taints to isolate system workloads
- Advanced Container Networking Services provides:
  - **Container Network Observability**: Enhanced visibility into network traffic
  - **Container Network Security**: FQDN filtering and other security features

## Advanced Container Networking Services

This module enables Advanced Container Networking Services (ACNS), which includes:

1. **Container Network Observability**: Provides deep insights into your network traffic by leveraging Hubble metrics, CLI, and UI. This helps with:
   - Detecting and determining root causes of network issues
   - Monitoring application performance
   - Ensuring security compliance

2. **Container Network Security**: For clusters using Azure CNI Powered by Cilium (as configured in this module), this provides:
   - DNS-based policies (FQDN filtering)
   - Simplified configuration management by using domain names instead of IP addresses
   - Enhanced security control over network policies

> **Note**: Advanced Container Networking Services is a paid offering. For more information about pricing, see [Advanced Container Networking Services - Pricing](https://azure.microsoft.com/pricing/details/kubernetes-service/).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This module is licensed under the [CC BY-NC 4.0 license](https://creativecommons.org/licenses/by-nc/4.0/).  
You may use, modify, and share this code **for non-commercial purposes only**.

If you wish to use it in a commercial project (e.g., as part of client infrastructure or a paid product), you must obtain a commercial license.

📬 Contact: mathias@monsieurdahlstrom.com