resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_private_endpoint" "keyvault_pe" {
  name                = "keyvault-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.aks_subnet.id

  private_service_connection {
    name                           = "keyvault-psc"
    private_connection_resource_id = azurerm_key_vault.vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_dns.id]
  }
}

resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_link" {
  name                  = "kv-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name
  virtual_network_id    = azurerm_virtual_network.aks_vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network_peering" "aks_to_app" {
  count                     = var.app_vnet_resource_group != "" && var.app_vnet_name != "" ? 1 : 0
  name                      = "aks-to-app"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.aks_vnet.name
  remote_virtual_network_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.app_vnet_resource_group}/providers/Microsoft.Network/virtualNetworks/${var.app_vnet_name}"
}

resource "azurerm_virtual_network_peering" "app_to_aks" {
  count                     = var.app_vnet_resource_group != "" && var.app_vnet_name != "" ? 1 : 0
  name                      = "app-to-aks"
  resource_group_name       = var.app_vnet_resource_group
  virtual_network_name      = var.app_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.aks_vnet.id
}
