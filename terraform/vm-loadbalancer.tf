# ============================================================
# VM LOAD BALANCER — Anggota 4
# 1 VM Nginx reverse proxy, satu-satunya VM yang punya public IP
# ============================================================

# ── Public IP untuk Load Balancer ────────────────────────────
resource "azurerm_public_ip" "lb" {
  name                = "${var.project_name}-${var.environment}-lb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# ── Network Interface untuk Load Balancer ────────────────────
resource "azurerm_network_interface" "lb" {
  name                = "${var.project_name}-${var.environment}-lb-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lb.id
  }
}

# ── VM Load Balancer ─────────────────────────────────────────
resource "azurerm_linux_virtual_machine" "lb" {
  name                = "${var.project_name}-${var.environment}-lb-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.lb.id]

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
    Role = "loadbalancer"
  })
}
