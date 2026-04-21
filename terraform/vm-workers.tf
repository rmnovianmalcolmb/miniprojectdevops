# ============================================================
# VM WORKERS
# 1 Frontend Worker + 1 Backend Worker
# Private IPs only — SSH access via LB jump host
# ============================================================

# ── Network Interface Frontend ────────────────────────────────
resource "azurerm_network_interface" "frontend" {
  count               = 1
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

# ── VM Frontend ───────────────────────────────────────────────
resource "azurerm_linux_virtual_machine" "frontend" {
  count               = 1
  name                = "${var.project_name}-${var.environment}-frontend-vm"
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

# ── Network Interface Backend ─────────────────────────────────
resource "azurerm_network_interface" "backend" {
  count               = 1
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

# ── VM Backend ────────────────────────────────────────────────
resource "azurerm_linux_virtual_machine" "backend" {
  count               = 1
  name                = "${var.project_name}-${var.environment}-backend-vm"
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
