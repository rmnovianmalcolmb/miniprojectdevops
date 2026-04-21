# 🎫 Mini Project DevOps - Concert Ticketing Infrastructure

Infrastruktur tiket konser berbasis Azure Cloud yang dirancang untuk menangani trafik tinggi (war ticket) dengan implementasi Load Balancing, Containerization, dan Automasi.

## 👥 Anggota Kelompok 5
| No | NRP | Nama Lengkap |
|:---:|:---:|:---|
| 1 | 5027221051 | DITYA WAHYU RAMADHAN |
| 2 | 5027231003 | CHELSEA VANIA HARIYONO |
| 3 | 5027231016 | DIAN ANGGRAENI PUTRI |
| 4 | 5027231035 | RM. NOVIAN MALCOLM BAYUPUTRA |
| 5 | 5027231058 | NICHOLAS ARYA KRISNUGROHO RERANGIN |
| 6 | 5027231072 | AISYAH RAHMASARI |
| 7 | 5027231084 | FARAND FEBRIANSYAH |
---

<br>

## 📖 1. Latar Belakang & Solusi Studi Kasus

### Problem Statement
Sebuah promotor musik kerap mengalami insiden **server down** setiap kali menyelenggarakan *war ticket* untuk konser artis internasional. Masalah utamanya adalah:
1. **Lonjakan Trafik Masif**: Ribuan user mengakses web di detik yang sama.
2. **Single Point of Failure**: Infrastruktur lama tidak memiliki distribusi beban.
3. **Ketidakamanan Data**: Container dan jaringan belum terstandarisasi.

**Solusi yang Kami Bangun:**
Kami merancang ulang sistem menggunakan arsitektur **High Availability (HA)**. Dengan 1 Load Balancer dan 4 Worker Nodes, sistem dipastikan tidak akan tumbang meski salah satu node mengalami gangguan. Seluruh proses dari pembuatan network hingga aplikasi berjalan otomatis (Zero Manual Setup).

<br>

## 🏗️ 2. Arsitektur Sistem
Sistem ini dirancang untuk skalabilitas horizontal, menangani lonjakan trafik tinggi (ticket war) dengan pendekatan **load balancing + containerized services** di atas infrastruktur cloud Azure. Jika trafik meningkat, tim hanya perlu menambah jumlah Worker Node di skrip Terraform.

```
                         ┌──────────────────────┐
                         │        User          │
                         │ (Web Browser / API)  │
                         └──────────┬───────────┘
                                    │ HTTP Request (Port 80)
                                    ▼
                         ┌──────────────────────┐
                         │   Load Balancer VM   │
                         │      (Nginx)         │
                         │   Public IP: XX.X    │
                         └──────────┬───────────┘
                     ┌──────────────┼──────────────┐
                     │ (Proxy Pass) │ (Proxy Pass) │
                     ▼              ▼              ▼
        ┌──────────────────────┐      ┌──────────────────────┐
        │ Frontend Worker 1    │      │ Frontend Worker 2    │
        │ Docker Container     │      │ Docker Container     │
        │ Port: 8080           │      │ Port: 8080           │
        └──────────────────────┘      └──────────────────────┘

                     ┌──────────────┼──────────────┐
                     │              │              │
                     ▼              ▼              ▼
        ┌──────────────────────┐      ┌──────────────────────┐
        │ Backend Worker 1     │      │ Backend Worker 2     │
        │ Docker Container     │      │ Docker Container     │
        │ Port: 3000           │      │ Port: 3000           │
        └──────────────────────┘      └──────────────────────┘
```
![Arsitektur Sistem](/docs/screenshots/image.png)
### Detil Komponen Infrastruktur Azure
| Resource | Spesifikasi | Deskripsi |
| :--- | :--- | :--- |
| **Region** | East Asia (Hong Kong) | Dipilih untuk latensi terendah bagi pengguna di Asia Tenggara. |
| **Virtual Network** | 10.0.0.0/16 | Jaringan privat yang terisolasi dari internet publik. |
| **Subnet** | 10.0.1.0/24 | Subnet internal tempat seluruh VM berada. |
| **VM Size** | Standard_B2as_v2 | 2 vCPU, 8GB RAM (Burstable) - Cocok untuk lonjakan trafik tiba-tiba. |
| **OS Image** | Ubuntu 24.04 LTS | Sistem operasi Linux terbaru dengan dukungan keamanan jangka panjang. |

<br>

## ☁️ 3. Tahap Infrastructure as Code (Terraform)
Kami menggunakan **Terraform** untuk memastikan infrastruktur dapat dibuat ulang (reproducible) dalam waktu kurang dari 2 menit. Seluruh resource dikelompokkan dalam Resource Group yang terisolasi.
### Resource yang Diprovisioning:
| Resource | Nama | Keterangan |
|----------|------|------------|
| **Resource Group** | `concert-ticketing-dev-rg` | Wadah semua resource Azure |
| **Virtual Network** | `concert-ticketing-dev-vnet` | Address space: `10.0.0.0/16` |
| **Subnet** | `concert-ticketing-dev-subnet` | CIDR: `10.0.1.0/24` (Isolated) |
| **Network Security Group** | `concert-ticketing-dev-nsg` | Firewall level jaringan |
| **Public IP** | `lb-public-ip` | Hanya dialokasikan untuk Load Balancer |
### Keamanan Jaringan (NSG Inbound Rules)
Kami menerapkan kebijakan **Deny-All-Inbound** di akhir rule untuk memastikan tidak ada celah keamanan yang terbuka secara tidak sengaja.
| Priority | Nama | Protocol | Port | Source | Action | Keterangan |
|:---:|:---|:---:|:---:|:---|:---:|:---|
| 100 | Allow-HTTP | TCP | 80 | Internet | Allow | Akses User ke LB |
| 110 | Allow-HTTPS | TCP | 443 | Internet | Allow | Akses Secure User |
| 120 | Allow-SSH | TCP | 22 | Admin IP | Allow | Remote Management |
| 200 | Allow-Internal | Any | Any | VNet | Allow | Komunikasi antar Node |
| 4000 | Deny-All | Any | Any | Any | Deny | Block trafik lain |

<br>

## 📂 4. Struktur Direktori Terraform

```text
terraform/
├── main.tf          <- Konfigurasi Provider Azure
├── variables.tf     <- Definisi variabel (Region, IP, vCPU)
├── terraform.tfvars <- Nilai input variabel
├── network.tf       <- RG, VNet, dan Subnet
├── security.tf      <- NSG dan Firewall Rules
└── outputs.tf       <- Mengekspos Subnet ID & IP untuk Ansible
```

<br>

## 🐋 5. Tahap 1: Kontainerisasi Aplikasi (Docker)
Sesuai dengan standar industri, kami menggunakan pendekatan **Multi-stage Build**. Teknik ini memastikan *build tools* yang berat tidak ikut masuk ke dalam image produksi, sehingga menghasilkan image yang sangat ringan, cepat di-deploy, dan memiliki celah keamanan minimal (*attack surface reduction*).
### 📱 A. Service A: Frontend (Web Ticketing)
Layanan frontend bertugas menampilkan antarmuka sistem tiket kepada pengguna.
1. **Strategi Build**:
    - **Stage 1 (Builder)**: Menggunakan `node:20-alpine` untuk memproses *source code* dan aset statis.
    - **Stage 2 (Production)**: Menggunakan `nginx:1.30-alpine-slim` sebagai runtime.
2. **Optimalisasi Ukuran**: Hasil akhir image hanya berukuran **5.7 MB**, menjamin efisiensi penyimpanan dan kecepatan *pull* di cluster worker.
3. **Standar Keamanan**:
    - **Non-Root User**: Container dijalankan sebagai user `nginx`, bukan root, untuk mencegah eskalasi privilese.
    - **Custom PID**: File PID dipindahkan ke `/tmp/nginx.pid` agar user non-root memiliki hak tulis.
    - **Security Headers**: Konfigurasi Nginx menyertakan `X-Frame-Options`, `X-Content-Type-Options`, dan `X-XSS-Protection`.

![docker front](/docs/screenshots/dockerfront.png)
### ⚙️ B. Service B: Backend (REST API)
Layanan backend menangani logika bisnis dan data tiket melalui endpoint API.
1. **Strategi Build**: Menggunakan `node:20-alpine` untuk efisiensi resource.
2. **Standar Keamanan**:
    - Implementasi `addgroup -S appgroup && adduser -S appuser -G appgroup`.
    - Perintah `USER appuser` memastikan aplikasi tidak memiliki akses ke sistem file sensitif di level OS host.
3. **Port Exposure**: Berjalan pada port internal `3000`.

<br>

## ⚠️ 6. Vulnerability Scanning: Docker Scout Audit
Sebelum dilakukan deployment ke Azure, setiap image wajib melalui tahap **Vulnerability Scan** menggunakan **Docker Scout**. Hal ini bertujuan untuk mendeteksi celah keamanan level *Critical* atau *High*.
### Hasil Audit Frontend Image
Berdasarkan scan mendalam terhadap image `concert-frontend:latest`:
| Severity | Count | Status | Keterangan |
| :--- | :---: | :---: | :--- |
| **Critical** | **0** | ✅ Clean | Tidak ditemukan celah kritis. |
| **High** | **0** | ✅ Clean | Tidak ditemukan celah berisiko tinggi. |
| **Medium** | 1 | ℹ️ Noted | Berasal dari base image Nginx (Non-actionable). |
| **Low** | 0 | ✅ Clean | - |
### Log Audit (Vulnerability Overview)
```text
v SBOM of image already cached, 26 packages indexed
v No vulnerable package detected
## Overview
Target          | concert-frontend:latest
vulnerabilities | 0C 0H 1M 0L
size            | 5.7 MB
packages        | 26
```
#### Hasil docker scout quickview 
![dockerscout](/docs/screenshots/dockerscout1.png)
#### Hasil docker scout cves --only-severity critical, high
![dockerscout](/docs/screenshots/dockerscout2.png)
### Mitigasi & Kesimpulan Scan:
Kami menggunakan base image bertipe **Alpine Slim** yang secara drastis mengurangi jumlah paket terinstal (hanya 26 paket). Dengan jumlah paket yang sedikit, risiko kerentanan perangkat lunak (CVE) menurun secara signifikan. Image dinyatakan **AMAN** untuk di-deploy ke lingkungan produksi Azure.

<br>

## 🧪 7. Validasi Lokal (Docker Compose)
Sebelum di-push ke registry, seluruh layanan diuji secara lokal menggunakan `docker-compose.yml`.
```yaml
services:
  frontend:
    image: concert-frontend:latest
    ports: ["8080:8080"]
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://127.0.0.1:8080/health"]
  backend:
    image: concert-backend:latest
    ports: ["3000:3000"]
```
**Hasil Verifikasi Lokal:**
*   Container Frontend berstatus `healthy`.
*   Endpoint `/health` mengembalikan status `200 OK`.
*   Integrasi antara frontend dan backend berjalan mulus melalui jaringan internal Docker.
![dockerps](/docs/screenshots/dockerps.png)

<br>

## 🤖 8. Tahap 3: Configuration as Code (Ansible)
Setelah infrastruktur jaringan dan VM berhasil diprovisioning oleh Terraform, tim menggunakan **Ansible** untuk melakukan konfigurasi otomatis secara massal pada ke-5 VM. Hal ini menjamin bahwa seluruh node memiliki konfigurasi software yang identik dan *reproducible*.
### A. Strategi Manajemen Inventory
Kami menggunakan struktur inventory yang terorganisir untuk membedakan antara node Load Balancer, Frontend, dan Backend. Hal ini memungkinkan Ansible menjalankan *task* yang berbeda secara spesifik pada setiap kelompok server.
```yaml
all:
  children:
    loadbalancer:
      hosts:
        lb-01: { ansible_host: 20.24.192.173 }
    frontend_workers:
      hosts:
        fe-01: { ansible_host: 10.0.1.4 }
        fe-02: { ansible_host: 10.0.1.5 }
    backend_workers:
      hosts:
        be-01: { ansible_host: 10.0.1.6 }
        be-02: { ansible_host: 10.0.1.7 }
```
### B. Otomatisasi Deployment (Playbooks)
Tim menyusun master playbook `site.yml` yang mencakup seluruh alur kerja CaC:
1. **System Preparation**: Instalasi Docker Engine dan Docker Compose Plugin di seluruh VM.
2. **Image Distribution**: Menarik (*pull*) image `concert-frontend:latest` dan `concert-backend:latest` dari registry ke masing-masing worker node.
3. **Container Orchestration**: Menjalankan container dengan parameter port yang sudah ditentukan (Frontend: 8080, Backend: 3000).
### C. Verifikasi Keberhasilan Deployment
Setelah Ansible selesai menjalankan *task*, kami melakukan verifikasi langsung pada node worker. Container dipastikan berjalan stabil dengan status `healthy`.

<br>

## ⚖️ 9. Konfigurasi Load Balancer (Nginx Reverse Proxy)
Sebagai solusi atas masalah *server down* pada studi kasus, kami mengonfigurasi VM Load Balancer untuk mendistribusikan trafik secara cerdas ke 4 worker node.
### Metode: Least Connections
Berdasarkan analisis kebutuhan *war ticket*, kami menerapkan metode **Least Connections**. 
* **Keunggulan**: Nginx akan memantau jumlah koneksi aktif pada setiap worker node dan mengirimkan request baru ke server yang memiliki beban paling ringan. Hal ini jauh lebih efektif dibanding Round Robin dalam menangani request dinamis yang berat.
### Upstream Configuration (Jinja2 Template):
```nginx
upstream frontend_cluster {
    least_conn;
    server 10.0.1.4:8080 max_fails=3 fail_timeout=30s;
    server 10.0.1.5:8080 max_fails=3 fail_timeout=30s;
}

upstream backend_cluster {
    least_conn;
    server 10.0.1.6:3000 max_fails=3 fail_timeout=30s;
    server 10.0.1.7:3000 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    server_name ticketing.concert.com;

    location / {
        proxy_pass http://frontend_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api/ {
        proxy_pass http://backend_cluster;
    }
}
```

## 🛡️ 10. Keamanan Akses: SSH ProxyJump (Bastion Host)
Demi keamanan, 4 Worker VM kami tempatkan di **Private Subnet** tanpa IP Publik.
1. **Bastion Host**: VM Load Balancer berfungsi sebagai gerbang masuk satu-satunya (Bastion Host).
2. **Ansible Proxy**: Konfigurasi `ansible_ssh_common_args` menggunakan perintah `-o ProxyJump` untuk melompat dari LB ke server internal secara aman.
3. **Dampak**: Peretas dari internet tidak dapat melakukan serangan *brute-force* SSH langsung ke server aplikasi kami.

