# Terraform — Networking Infrastructure

Direktori ini berisi konfigurasi Terraform untuk menyiapkan **layer jaringan** dari infrastruktur Concert Ticketing di Microsoft Azure.

## Resource yang Dibuat

| Resource | Nama | Keterangan |
|----------|------|------------|
| Resource Group | `concert-ticketing-dev-rg` | Wadah semua resource Azure |
| Virtual Network | `concert-ticketing-dev-vnet` | Address space: `10.0.0.0/16` |
| Subnet | `concert-ticketing-dev-subnet` | CIDR: `10.0.1.0/24` |
| Network Security Group | `concert-ticketing-dev-nsg` | Lihat tabel rules di bawah |

## NSG Rules

| Priority | Nama | Direction | Protocol | Port | Source | Action |
|----------|------|-----------|----------|------|--------|--------|
| 100 | Allow-HTTP-Inbound | Inbound | TCP | 80 | Internet | Allow |
| 110 | Allow-HTTPS-Inbound | Inbound | TCP | 443 | Internet | Allow |
| 120 | Allow-SSH-Admin | Inbound | TCP | 22 | `admin_source_ip` | Allow |
| 200 | Allow-Internal-VNet | Inbound | Any | Any | VirtualNetwork | Allow |
| 300 | Allow-AzureLoadBalancer | Inbound | Any | Any | AzureLoadBalancer | Allow |
| 4000 | Deny-All-Inbound | Inbound | Any | Any | Any | Deny |
| 100 | Allow-Outbound-Internet | Outbound | Any | Any | Any | Allow |

## Struktur File

```
terraform/
├── main.tf          <- Provider Azure + versi Terraform
├── variables.tf     <- Semua variabel yang bisa dikonfigurasi
├── terraform.tfvars <- Nilai default variabel
├── network.tf       <- Resource Group, VNet, Subnet
├── security.tf      <- NSG + rules
└── outputs.tf       <- Output subnet_id & nsg_id untuk provisioning VM
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Akun Azure aktif (Azure for Students tersedia gratis dengan kredit $100)

## Cara Menjalankan

### 1. Login ke Azure

```bash
az login
```

Verifikasi subscription yang aktif:

```bash
az account show
```

### 2. Inisialisasi Terraform

```bash
cd terraform/
terraform init
```

### 3. Kustomisasi Variabel (opsional)

Edit `terraform.tfvars` sesuai kebutuhan, misalnya membatasi akses SSH ke IP tertentu:

```hcl
admin_source_ip = "YOUR_PUBLIC_IP/32"
```

Untuk mengecek IP publik: `curl ifconfig.me`

### 4. Preview Perubahan

```bash
terraform plan
```

Seharusnya menampilkan **7 resources to add**: 1 Resource Group, 1 VNet, 1 Subnet, 1 NSG, dan 5 NSG rules.

### 5. Apply

```bash
terraform apply
```

Ketik `yes` saat diminta konfirmasi. Proses provisioning biasanya selesai dalam 1-2 menit.

### 6. Lihat Output

Setelah apply berhasil, jalankan:

```bash
terraform output networking_summary
```

Contoh output:

```
networking_summary = {
  "location"            = "Southeast Asia"
  "nsg_id"              = "/subscriptions/.../networkSecurityGroups/concert-ticketing-dev-nsg"
  "resource_group_name" = "concert-ticketing-dev-rg"
  "subnet_id"           = "/subscriptions/.../subnets/concert-ticketing-dev-subnet"
}
```

Nilai `subnet_id` dan `nsg_id` dibutuhkan untuk provisioning VM di langkah berikutnya.

### 7. Destroy

```bash
terraform destroy
```
