# ============================================================
# terraform.tfvars — Default Values (Anggota 3 Networking)
# Ubah nilai di sini sesuai kebutuhan tim
# ============================================================

# Lokasi Azure (pilih yang dekat: Southeast Asia = Singapore)
location = "Southeast Asia"

# Nama proyek — jadi prefix semua resource
project_name = "concert-ticketing"

# Environment
environment = "dev"

# Networking
vnet_address_space    = ["10.0.0.0/16"]
subnet_address_prefix = "10.0.1.0/24"

# IP admin untuk SSH
# PENTING: Ganti dengan IP publik kamu sebelum apply ke production!
# Cek IP kamu di: https://whatismyip.com
# Contoh: admin_source_ip = "203.0.113.10/32"
admin_source_ip = "*"

# Tags
tags = {
  Project     = "concert-ticketing-infra"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "Anggota3-Networking"
  Course      = "DevOps-MiniProject"
}
