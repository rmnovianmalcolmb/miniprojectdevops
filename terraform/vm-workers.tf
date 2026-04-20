# ============================================================
# VM WORKERS — Anggota 4
# 2 Frontend Workers + 2 Backend Workers
# Hanya private IP — SSH akses via LB sebagai jump host
# ============================================================

# ── Network Interface Frontend Workers ───────────────────────
resource "azurerm_network_interface" "frontend" {
  count               = 2
  name                = "${var.project_name}-${var.environment}-frontend-nic-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

# ── VM Frontend Workers ───────────────────────────────────────
resource "azurerm_linux_virtual_machine" "frontend" {
  count               = 2
  name                = "${var.project_name}-${var.environment}-frontend-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.frontend[count.index].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = merge(var.tags, {
    Role = "frontend"
  })
}

# ── Network Interface Backend Workers ────────────────────────
resource "azurerm_network_interface" "backend" {
  count               = 2
  name                = "${var.project_name}-${var.environment}-backend-nic-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

# ── VM Backend Workers ────────────────────────────────────────
resource "azurerm_linux_virtual_machine" "backend" {
  count               = 2
  name                = "${var.project_name}-${var.environment}-backend-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.backend[count.index].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = merge(var.tags, {
    Role = "backend"
  })
}
