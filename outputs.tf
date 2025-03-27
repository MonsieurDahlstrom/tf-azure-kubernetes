output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azapi_resource.aks.id
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azapi_resource.aks.name
}

output "kube_config" {
  description = "Kubernetes configuration for the cluster"
  value       = azapi_resource_action.aks_kubeconfig.output.kubeconfigs[0].value
  sensitive   = true
}

output "cluster_endpoint" {
  description = "The Kubernetes cluster server endpoint"
  value       = azapi_resource.aks.output.properties.fqdn
}

# For extracting the CA certificate, we'd need to actually parse the kubeconfig YAML
# Since the full kubeconfig is already available in the kube_config output, 
# we're removing this redundant output to avoid confusion
# The end user can extract the CA certificate from the kubeconfig if needed

output "cluster_identity" {
  description = "The identity of the AKS cluster"
  value       = azurerm_user_assigned_identity.aks
} 