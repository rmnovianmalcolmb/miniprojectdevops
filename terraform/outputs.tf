# ============================================================
# OUTPUTS — Anggota 3 (Networking)
# Output kritis yang DIBUTUHKAN oleh Anggota 4 (Terraform VMs)
# ============================================================

# ── Output untuk Anggota 4 ───────────────────────────────────
# Anggota 4 akan menggunakan output ini dengan:
#   data "terraform_remote_state" atau copy manual nilai setelah terraform apply

output "subnet_id" {
  description = "ID subnet utama — dipakai Anggota 4 untuk attach NIC semua VM"
  value       = azurerm_subnet.main.id
}

output "nsg_id" {
  description = "ID Network Security Group — dipakai Anggota 4 untuk attach ke NIC VM"
  value       = azurerm_network_security_group.main.id
}

# ── Output Informatif ────────────────────────────────────────

output "resource_group_name" {
  description = "Nama Resource Group — dipakai semua anggota untuk deploy resource ke RG yang sama"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Lokasi Resource Group"
  value       = azurerm_resource_group.main.location
}

output "vnet_id" {
  description = "ID Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Nama Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "CIDR block Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}

output "subnet_name" {
  description = "Nama subnet utama"
  value       = azurerm_subnet.main.name
}

output "subnet_address_prefix" {
  description = "CIDR block subnet utama"
  value       = azurerm_subnet.main.address_prefixes[0]
}

output "nsg_name" {
  description = "Nama Network Security Group"
  value       = azurerm_network_security_group.main.name
}

# ── Summary untuk Anggota 4 ──────────────────────────────────
output "networking_summary" {
  description = "Ringkasan nilai penting yang perlu dicopy ke konfigurasi Anggota 4"
  value = {
    subnet_id           = azurerm_subnet.main.id
    nsg_id              = azurerm_network_security_group.main.id
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
  }
}
