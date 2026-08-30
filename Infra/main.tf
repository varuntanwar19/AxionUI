resource "azurerm_resource_group" "rg" {
  name     = "rg-aks"
  location = "westus"
}

resource "azurerm_container_registry" "acr" {
  name                = "azurgjgjacr"   # must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true 
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "eaks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdns"
  #kubernetes_version  = "1.34.8"
  


  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2alds_v7"
  }

    node_provisioning_profile {
    mode = "Auto"
  }


  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true


}

# resource "azurerm_role_assignment" "acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
# }
