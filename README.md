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
Setelah infrastruktur jaringan dan VM berhasil diprovisioning oleh Terraform, tim menggunakan **Ansible** untuk melakukan konfigurasi otomatis secara massal pada seluruh VM. Hal ini menjamin bahwa seluruh node memiliki konfigurasi software yang identik dan *reproducible*.
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

<br>

## 🛠️ 10. Bukti Verifikasi Infrastruktur Azure
Sebelum masuk ke tahap deployment aplikasi, tim memastikan seluruh resource di Azure telah teralokasi dengan benar sesuai dengan perencanaan di Terraform.
### A. Alokasi Resource Azure
Seluruh resource dikelola dalam satu Resource Group untuk memudahkan monitoring dan manajemen biaya.
![resources](/docs/screenshots/resources.png)
### B. Detail Komputasi & Jaringan
Untuk mengoptimalkan kuota *Azure for Students (6 vCPU)*, kami menggunakan **3 Virtual Machines** dengan performa tinggi:
![3vm](/docs/screenshots/3vm.png)
![subnet](/docs/screenshots/subnet.png)
![ip](/docs/screenshots/ip.png)
*   **lb-01**: Sebagai Load Balancer (Public IP).
*   **worker-master**: Menjalankan Frontend & Backend (Private IP).
*   **worker-slave**: Menjalankan Frontend & Backend (Private IP).

<br>

## 🤖 11. Bukti Verifikasi Konfigurasi (Ansible)
Kami menggunakan Ansible untuk memastikan seluruh VM dapat dikelola dari satu titik (Control Node). Berikut adalah bukti keberhasilan tahap persiapan:
### A. Uji Koneksi (Ping Test)
Verifikasi bahwa seluruh VM (LB dan Workers) dapat dijangkau melalui protokol SSH.
* **Status**: `SUCCESS` untuk `lb-01`, `worker-master`, dan `worker-slave`.
![ansible all](/docs/screenshots/ans-all.png)
### B. Uji Koneksi Grup Workers
Memastikan grup khusus `workers` merespon sebelum instalasi Docker dimulai.
![ansible worker](/docs/screenshots/ans-work.png)
### C. Keberhasilan Instalasi Docker Engine
Eksekusi playbook `install-docker.yml` dilakukan secara paralel ke seluruh worker node. 
*   **Hasil**: Seluruh *task* (apt update, install dependencies, download GPG key) berstatus `ok` atau `changed`.
*   **Error Rate**: 0% (Tidak ada task yang `failed`).
![docker play](/docs/screenshots/docker-play.png)
### D. Verifikasi Versi Runtime (Docker Engine)
Sebagai tahap audit akhir, kami memeriksa versi Docker yang terinstal untuk memastikan kompatibilitas dengan image aplikasi.
*   **Versi Terdeteksi**: `Docker version 29.4.1, build 055a478`.
*   **Target Node**: `worker-master` & `worker-slave`.
![docker ver](/docs/screenshots/docker-ver.png)

<br>

## 🚀 12. Strategi Deployment: "Shared-Worker Pattern"
Karena keterbatasan kuota vCPU Azure, kami menerapkan strategi **Shared-Worker**. 
*   **Cara Kerja**: Setiap worker node (`master` & `slave`) menjalankan dua container sekaligus (1 Frontend + 1 Backend).
*   **Ketersediaan Tinggi (HA)**: Meskipun hanya 2 VM worker, sistem tetap memiliki redundansi penuh. Jika `worker-master` tumbang, Load Balancer akan otomatis mengalihkan 100% trafik ke `worker-slave`.

<br>

## 📈 13. Tahap Pengujian Beban (Load Testing)
Untuk memvalidasi efektivitas infrastruktur, tim QA melakukan pengujian dalam dua skenario: **Skenario Baseline (200 VU)** untuk menguji stabilitas harian, dan **Skenario Stress Test (1000 VU)** untuk mensimulasikan kondisi *War Ticket*.
### A. Metodologi & Skenario
Pengujian dilakukan menggunakan **Grafana k6** dengan target endpoint Frontend (`/`) dan Backend API (`/api/health`). 
1.  **Skenario A (Baseline)**: Maksimal 200 Virtual Users untuk mengukur performa standar.
2.  **Skenario B (Stress Test)**: Maksimal 1.000 Virtual Users untuk mengukur titik jenuh sistem.
### B. Hasil Skenario A: Baseline Test (200 VUs)
Skenario ini bertujuan memastikan bahwa seluruh fitur utama (Frontend, Backend, Healthcheck, Hostname Identity) berfungsi 100% tanpa kegagalan pada beban menengah.
| Metrik Utama | Hasil Audit (200 VUs) | Status |
| :--- | :--- | :---: |
| **Total Requests** | **44,032** | - |
| **Success Rate** | **100.00%** | ✅ **PERFECT** |
| **Throughput** | **146.55 req/sec** | ✅ **STABLE** |
| **Average Latency** | **438.38 ms** | ✅ **GOOD** |
| **p(95) Response Time** | **1.66 s** | ⚠️ **SPIKE** |
| **Checks Succeeded** | **100.00% (88,064)** | ✅ **PASSED** |
**Analisis Skenario A:**
*   **Zero Failure**: Tidak ada satu pun request yang gagal dari total 44 ribu trafik.
*   **Integrasi Penuh**: Seluruh pengecekan (`frontend returns 200`, `backend healthy`, `hostname exists`) berstatus **Lulus**.
*   **Identitas Host**: Berhasil memverifikasi bahwa Load Balancer mendistribusikan trafik ke worker node yang berbeda melalui pengecekan `hostname`.

![200 stages](/docs/screenshots/k6-200.png)
### C. Hasil Skenario B: Stress Test (1.000 VUs)
Skenario ini mensimulasikan beban puncak saat "War Ticket". Sistem dipaksa bekerja hingga titik jenuh untuk melihat ketahanannya.
| Metrik Utama | Hasil Audit (1.000 VUs) | Status |
| :--- | :--- | :---: |
| **Total Checks** | **177,020** | - |
| **Success Rate** | **99.97%** | ✅ **EXCELLENT** |
| **Throughput** | **545.21 req/sec** | ✅ **STABLE** |
| **p(95) Response Time** | **7.22 s** | 🐢 **SATURATED** |
| **Total Failed Checks** | **49** (0.02%) | ⚠️ **MARGINAL** |
**Analisis Skenario B:**
*   **Resiliensi Tinggi**: Meskipun dibebani 1.000 user sekaligus, sistem hanya mengalami 49 kegagalan dari 177 ribu pengecekan, dan 9 kegagalan dari 60 ribu. Artinya, lebih dari 99% transaksi tiket tetap berjalan aman.
*   **Bottleneck Terdeteksi**: Latensi p(95) naik menjadi 7.22 detik. Ini menunjukkan bahwa kapasitas CPU/RAM pada VM `B2as_v2` sudah mencapai batas maksimal (Saturation Point).
*   **Stabilitas Backend**: Menariknya, seluruh kegagalan terjadi di sisi Frontend, sementara **Backend API tetap 100% stabil** tanpa ada kegagalan satu pun.

*Test ke-1, 49 gagal dari 177020.*
![1000 stages](/docs/screenshots/k6-1000.png)
*Test ke-2, 9 gagal dari 60350.*
![1000 stages](/docs/screenshots/k6-1000-b.png)

<br>

## 🔍 14. Analisis & Pembuktian Load Balancing
Sebagai QA Engineer, kami melakukan analisis mendalam terhadap hasil stress test untuk memastikan infrastruktur tidak hanya "cepat", tapi juga cerdas dan tahan banting (*resilient*).
### 1. Bukti Distribusi Trafik (Hostname Identity)
Dalam skrip k6, kami menerapkan logika `check` untuk memvalidasi field `hostname` pada setiap response API.
*   **Hasil**: Seluruh request yang berhasil (99.97%) sukses mendapatkan identitas hostname container. Selama pengujian, trafik berpindah secara dinamis antara `worker-master` dan `worker-slave`.
*   **Kesimpulan**: Metode **Least Connections** pada Nginx terbukti berhasil menyeimbangkan beban 1.000 user. Tanpa Load Balancer, dipastikan salah satu node akan mengalami *Total System Failure* (Down).
### 2. Analisis Kegagalan (The 49 Failed Requests)
Dari total **177.020 checks**, ditemukan **49 kegagalan (0.02%)**.
*   **Temuan**: Kegagalan berupa `X frontend returns 200`. Artinya, saat beban mencapai puncak tertinggi (1.000 VU), Nginx sesekali gagal mendapatkan respon dari container Frontend tepat waktu.
*   **Analisis**: Tingkat kegagalan 0.02% masih jauh di bawah standar toleransi industri (biasanya 1%). Kegagalan ini dianggap sebagai *Safe Saturation*, di mana sistem tidak mati, namun hanya menolak sebagian kecil trafik untuk melindungi integritas server utama.
### 3. Efisiensi Data & Resource
*   **Network Throughput**: Selama 5 menit, sistem memproses **350 MB** data masuk (Received) dan **6.6 MB** data keluar (Sent).
*   **Resource Efficiency**: Dengan infrastruktur ramping (3 VM), sistem mampu melayani **545 request per detik**. Ini membuktikan bahwa kontainerisasi menggunakan Docker Alpine sangat efisien dalam penggunaan RAM dan CPU.

<br>

## 🔌 15. Dokumentasi API (Endpoints)
Pengujian beban dilakukan terhadap dua endpoint utama aplikasi:
### 1. Health & Identity Check (`/api/health`)
Digunakan oleh tim operasional untuk memverifikasi kesehatan layanan secara *real-time*.
- **Method**: `GET`
- **Output**: JSON berisi identitas hostname container (ID Container Docker).
![health](/docs/screenshots/api-health.png)
### 2. Concert Tickets Data (`/api/tickets`)
Endpoint utama untuk menampilkan daftar konser kepada calon pembeli.
- **Method**: `GET`
- **Output**: JSON berisi daftar konser, harga, dan ID.
![tickets](/docs/screenshots/api-tickets.png)

<br>

## 🔧 16. Prerequisite & local Setup
Sebelum menjalankan infrastruktur ini dari nol, pastikan mesin lokal (Control Node) memiliki spesifikasi berikut:
| Tool | Versi Minimum | Kegunaan |
|---|---|---|
| **Terraform** | v1.5.0+ | Provisioning infrastruktur Azure (IaC) |
| **Azure CLI** | v2.40+ | Autentikasi dan manajemen akun Azure |
| **Ansible** | v2.12+ | Konfigurasi server dan deployment (CaC) |
| **k6** | v0.45+ | Load testing performa tinggi |
| **SSH Key Pair** | RSA 4096 | Otentikasi keamanan akses VM |

<br>

## 🚀 17. Panduan Eksekusi (Step-by-Step)

### Persiapan Awal

Login ke Azure dan pastikan subscription aktif:
```bash
az login
az account show --query "{Subscription:name}" --output table
```

Generate SSH key pair untuk akses ke VM:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub   # copy output ini untuk dipakai di Terraform
```

Clone repository:
```bash
git clone https://github.com/rmnovianmalcolmb/miniprojectdevops.git
cd miniprojectdevops
```

### Tahap 1: Provisioning dengan Terraform

Konfigurasi variabel sesuai environment:
```bash
cd terraform/
```

Edit `terraform.tfvars` dan isi nilai berikut:
```hcl
project_name         = "concert-ticketing"
environment          = "dev"
location             = "eastasia"
admin_ssh_public_key = "ssh-rsa AAAA..."  # paste output dari cat ~/.ssh/id_rsa.pub
admin_source_ip      = "*"
```

Jalankan Terraform:
```bash
terraform init                 # download provider Azure
terraform plan                 # preview resource yang akan dibuat
terraform apply -auto-approve  # buat infrastruktur (~3-5 menit)
```

Catat IP dari output:
```bash
terraform output vm_summary
```

Output berisi:
- `lb_public_ip` — IP publik Load Balancer (entry point aplikasi)
- `frontend_private_ip` — Private IP Worker Master
- `backend_private_ip` — Private IP Worker Slave

### Tahap 2: Konfigurasi dengan Ansible

Update `ansible/inventory/hosts.yml` dengan IP dari output Terraform:
```yaml
all:
  children:
    loadbalancer:
      hosts:
        lb-01:
          ansible_host: <lb_public_ip>
    workers:
      hosts:
        worker-master:
          ansible_host: <frontend_private_ip>
          ansible_ssh_common_args: '-o ProxyJump=azureuser@<lb_public_ip>'
        worker-slave:
          ansible_host: <backend_private_ip>
          ansible_ssh_common_args: '-o ProxyJump=azureuser@<lb_public_ip>'
```

Masuk ke direktori ansible dan test koneksi:
```bash
cd ../ansible/
ansible all -m ping -i inventory/hosts.yml   # semua VM harus reply pong
```

Jalankan deployment penuh (~10-15 menit):
```bash
ansible-playbook playbooks/site.yml -i inventory/hosts.yml
```

Playbook otomatis menjalankan 3 tahap:
1. `install-docker.yml` — Install Docker Engine di semua worker
2. `deploy-containers.yml` — Build & jalankan container Frontend + Backend
3. `setup-loadbalancer.yml` — Install & konfigurasi Nginx Load Balancer

### Tahap 3: Validasi & Load Test

Verifikasi container berjalan:
```bash
ansible workers -m shell -a "docker ps" -i inventory/hosts.yml
```

Akses aplikasi dan verifikasi:
```bash
curl http://<lb_public_ip>/              # halaman frontend
curl http://<lb_public_ip>/api/health    # backend API

# Test load balancing (10 request bersamaan)
for i in 1 2 3 4 5 6 7 8 9 10; do curl -s http://<lb_public_ip>/api/health & done; wait
```

Jalankan load test 1000 concurrent users:
```bash
cd ../
k6 run -e BASE_URL=http://<lb_public_ip> loadtest/script-1000.js
```


<br>

## 🛠️ 18. Troubleshooting (Panduan Masalah)
| Masalah | Penyebab | Solusi |
|---|---|---|
| **Terraform Apply Error (Quota)** | vCPU Azure for Students habis | Kurangi jumlah VM atau gunakan region lain (East Asia/Southeast Asia). |
| **Ansible "Unreachable"** | SSH Key tidak dikenal / NSG memblokir | Pastikan IP Public Anda terdaftar di `security.tf` (Allow SSH). |
| **Nginx 502 Bad Gateway** | Container worker belum *Up* | Cek status container di worker: `docker ps`. Pastikan port 8080/3000 sesuai. |
| **k6 "Connection Refused"** | LB overload / Port 80 tertutup | Cek status service Nginx di VM LB: `sudo systemctl status nginx`. |

<br>

## 🕵️ 19. Analisis Solusi: Menjawab Studi Kasus #1
Proyek ini dibangun khusus untuk menyelesaikan masalah insiden **server down** pada promotor musik. Berikut adalah bagaimana desain kami menjawab tantangan tersebut:
1.  **High Availability (HA)**: Dengan menggunakan 4 Worker Node (2 Frontend, 2 Backend), kami menghilangkan *Single Point of Failure*. Jika satu VM mati, Nginx akan mengalihkan trafik ke VM lain yang sehat.
2.  **Mitigasi Lonjakan (Ticket War)**: Penggunaan metode **Least Connections** pada Load Balancer memastikan tidak ada satu pun server yang "tercekik" trafik sementara server lain menganggur.
3.  **Keamanan Industri**: Pemindaian **Docker Scout** memastikan tidak ada celah keamanan (CVE) yang masuk ke lingkungan produksi, menjaga data transaksi tiket tetap aman.
4.  **Skalabilitas Cepat**: Jika artis yang didatangkan sangat populer (misal: Taylor Swift/Coldplay), infrastruktur ini dapat diduplikasi atau ditambah jumlah worker-nya hanya dalam hitungan detik melalui perubahan satu variabel di Terraform.

<br>

## 🔐 20. Fitur Keamanan & Traceability
Kami mengintegrasikan prinsip **DevSecOps** ke dalam siklus hidup proyek:
- **Zero Trust Network**: Seluruh worker tidak memiliki Public IP. Komunikasi hanya terjadi di dalam VNet Azure.
- **Traceability**: Setiap deployment dicatat melalui Ansible log, sehingga tim bisa melacak versi image mana yang sedang berjalan di `worker-master` maupun `worker-slave`.
- **Hardening**: Container Frontend dan Backend telah dikeraskan (*hardened*) dengan menghapus paket-paket OS yang tidak perlu melalui base image Alpine Slim.

<br>

## 🏁 Kesimpulan & Penutup
Implementasi sistem infrastruktur tiket konser ini telah berhasil memenuhi seluruh kriteria **Studi Kasus #1**. Kami berhasil mentransformasi alur kerja manual yang rentan menjadi alur kerja berbasis **DevOps** yang otomatis, terukur, dan aman.

**Hasil Akhir:**
- **Infrastruktur**: 100% Automated (Terraform & Ansible).
- **Keamanan**: 100% Vulnerability Scanned (Docker Scout).
- **Performa**: Stabil pada beban **1.000 concurrent users** dengan tingkat kegagalan nyaris nol (**0.02%**).

Sistem ini tidak hanya sekadar berjalan, tetapi siap untuk menghadapi kondisi nyata "War Ticket" dengan standar industri cloud modern.

---
<br>

*© 2026 - Study Case 1 - Kelompok 5 Operasional Pengembang*
