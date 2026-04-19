# ============================================================
# NETWORKING — Anggota 3
# Resource Group, Virtual Network, Subnet
# ============================================================

# ── Resource Group ───────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# ── Virtual Network ──────────────────────────────────────────
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-${var.environment}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
  tags                = var.tags

  # DNS server default Azure (168.63.129.16) sudah cukup untuk kebutuhan ini
}

# ── Subnet Utama ─────────────────────────────────────────────
# Satu subnet untuk semua VM (LB, frontend workers, backend workers)
resource "azurerm_subnet" "main" {
  name                 = "${var.project_name}-${var.environment}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_address_prefix]
}

# ── Subnet-NSG Association ───────────────────────────────────
# Hubungkan NSG (dari security.tf) ke subnet ini
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
