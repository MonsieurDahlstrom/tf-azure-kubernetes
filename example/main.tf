resource "random_pet" "bucket_prefix" {
  length = 4
}

resource "azurerm_resource_group" "this" {
  name     = "rg-test-aks-${random_pet.bucket_prefix.id}"
  location = "swedencentral"
}

# Create VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-test-${random_pet.bucket_prefix.id}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.0.0/22"]
}

# Create subnet for AKS nodes
resource "azurerm_subnet" "aks_nodes" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create subnet for AKS API server
resource "azurerm_subnet" "aks_api" {
  name                 = "snet-aks-api"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

module "aks" {
  source = "../"

  cluster_name        = "aks-test-${random_pet.bucket_prefix.id}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "aks-test-${random_pet.bucket_prefix.id}"

  vnet_id              = azurerm_virtual_network.vnet.id
  nodes_subnet_id      = azurerm_subnet.aks_nodes.id
  api_server_subnet_id = azurerm_subnet.aks_api.id

  tags = {
    Environment = "test"
    Project     = "aks-test"
  }
} 