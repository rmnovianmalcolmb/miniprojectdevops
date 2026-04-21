# ============================================================
# VARIABLES
# Konfigurasi Terraform yang bisa di-override
# ============================================================

# ── Lokasi & Nama Dasar ──────────────────────────────────────
variable "location" {
  description = "Azure region tempat semua resource dibuat"
  type        = string
  default     = "Southeast Asia"
}

variable "project_name" {
  description = "Nama proyek, dipakai sebagai prefix semua resource"
  type        = string
  default     = "concert-ticketing"
}

variable "environment" {
  description = "Environment (dev / staging / prod)"
  type        = string
  default     = "dev"
}

# ── Networking ───────────────────────────────────────────────
variable "vnet_address_space" {
  description = "CIDR block untuk Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "CIDR block untuk subnet utama"
  type        = string
  default     = "10.0.1.0/24"
}

# ── Keamanan ─────────────────────────────────────────────────
variable "admin_source_ip" {
  description = "IP publik admin untuk akses SSH (format: x.x.x.x/32). Gunakan * hanya untuk testing."
  type        = string
  default     = "*"
  # CATATAN KEAMANAN: Ganti dengan IP spesifik di production!
  # Contoh: "203.0.113.10/32"
}

# ── VM Config ──────────────────────────────
variable "admin_username" {
  description = "Username admin untuk semua VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key untuk autentikasi ke semua VM"
  type        = string
}

variable "vm_size" {
  description = "Ukuran VM Azure (default Standard_B1s = paling murah)"
  type        = string
  default     = "Standard_B1s"
}

# ── Tags ─────────────────────────────────────────────────────
variable "tags" {
  description = "Tags yang diterapkan ke semua resource"
  type        = map(string)
  default = {
    Project     = "concert-ticketing-infra"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
    Course      = "DevOps-MiniProject"
  }
}
