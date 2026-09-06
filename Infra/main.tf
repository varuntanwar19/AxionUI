data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aks"
  location = "westus"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "eaks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdns"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2alds_v7"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  node_provisioning_profile {
    mode = "Auto"
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  role_based_access_control_enabled = true
}

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "axionacr2029" # Must be globally unique, alphanumeric only
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

# PUSH Image to ACR (AcrPush Role)
resource "azurerm_role_assignment" "my_acr_push" {
  principal_id         = data.azurerm_client_config.current.object_id # <--- Your Object ID (or Pipeline Service Principal's Object ID)
  role_definition_name = "AcrPush"            # <--- Role for Pushing Docker Images
  scope                = azurerm_container_registry.acr.id
}

# Attach ACR to AKS Cluster (AcrPull Role)
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_user_assigned_identity" "aks_workload" {
  name                = "aks-workload-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_federated_identity_credential" "fed" {
  name                      = "fed-identity"
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject                   = "system:serviceaccount:default:sa"
  user_assigned_identity_id = azurerm_user_assigned_identity.aks_workload.id
}
