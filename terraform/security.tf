# ============================================================
# SECURITY
# Network Security Group + Rules
# ============================================================

# ── Network Security Group ───────────────────────────────────
resource "azurerm_network_security_group" "main" {
  name                = "${var.project_name}-${var.environment}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# ── Inbound Rules ────────────────────────────────────────────

# Rule 100: HTTP (port 80) — traffic ke Load Balancer dari internet
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "Allow-HTTP-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  description                 = "Izinkan traffic HTTP dari internet ke Load Balancer"
}

# Rule 110: HTTPS (port 443) — traffic HTTPS dari internet
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "Allow-HTTPS-Inbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  description                 = "Izinkan traffic HTTPS dari internet"
}

# Rule 120: SSH (port 22) — akses admin dari IP tertentu
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH-Admin"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.admin_source_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  description                 = "Izinkan SSH hanya dari IP admin (ganti * dengan IP spesifik di production)"
}

# Rule 200: Internal traffic — semua VM bisa saling berkomunikasi dalam VNet
resource "azurerm_network_security_rule" "allow_internal" {
  name                        = "Allow-Internal-VNet"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  description                 = "Izinkan semua traffic internal antar VM di dalam VNet"
}

# Rule 300: Azure Load Balancer probes — diperlukan Azure platform
resource "azurerm_network_security_rule" "allow_azure_lb" {
  name                        = "Allow-AzureLoadBalancer"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  description                 = "Izinkan health probe dari Azure Load Balancer"
}

# Rule 4000: Deny semua inbound lainnya (eksplisit, walau sudah default deny)
resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "Deny-All-Inbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  description                 = "Tolak semua traffic inbound yang tidak diizinkan rule di atas"
}

# ── Outbound Rules ───────────────────────────────────────────
# Default Azure sudah Allow All Outbound, tapi kita tambahkan eksplisit

# Rule 100: Outbound internet — untuk pull Docker image, update, dll
resource "azurerm_network_security_rule" "allow_outbound_internet" {
  name                        = "Allow-Outbound-Internet"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  description                 = "Izinkan semua outbound ke internet (pull image, update package, dll)"
}
