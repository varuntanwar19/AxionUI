
resource "azurerm_key_vault" "vault" {
  name                = "azrkeyvault-axion-2026"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  # Policy 1: Terraform/Logged-in User Permission (Required to create Secrets)
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover"
    ]
  }

  # Policy 2: AKS Kubelet Identity Permission
  access_policy {
    tenant_id = var.tenant_id
    object_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }
  # Policy 3: Workload Identity Access Permission
   access_policy {
    tenant_id = var.tenant_id
    object_id    = azurerm_user_assigned_identity.aks_workload.principal_id

    secret_permissions = [
      "Get",
      "List"
    ]

  }
}

resource "azurerm_key_vault_secret" "postgres_db" {
  name         = "postgres-db"
  value        = var.postgres_db
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "postgres_user" {
  name         = "postgres-user"
  value        = var.postgres_user
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "pgadmin_email" {
  name         = "pgadmin-email"
  value        = var.pgadmin_email
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "telemetry_db_url" {
  name         = "telemetry-database-url"  # Key Vault mein Secret Name Unique rakho
  value        = var.database_url          # Value wahi same variable se uthayega!
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "pgadmin_password" {
  name         = "pgadmin-password"
  value        = var.pgadmin_password
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "database_url" {
  name         = "database-url"
  value        = var.database_url
  key_vault_id = azurerm_key_vault.vault.id
}

