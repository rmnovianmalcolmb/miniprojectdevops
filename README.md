# Mini Project DevOps - Concert Ticketing Infrastructure

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

## 🏗️ Arsitektur Sistem
Sistem ini dirancang untuk menangani lonjakan trafik tinggi (ticket war) dengan pendekatan **load balancing + containerized services** di atas infrastruktur cloud Azure.

```
                         ┌──────────────────────┐
                         │        User          │
                         │ (Web Browser / API)  │
                         └──────────┬───────────┘
                                    │ HTTP Request
                                    ▼
                         ┌──────────────────────┐
                         │   Load Balancer VM   │
                         │      (Nginx)         │
                         │   Public IP: XX.X    │
                         └──────────┬───────────┘
                     ┌──────────────┼──────────────┐
                     │                              │
                     ▼                              ▼
        ┌──────────────────────┐      ┌──────────────────────┐
        │ Frontend Worker 1    │      │ Frontend Worker 2    │
        │ Docker Container     │      │ Docker Container     │
        │ Port: 80             │      │ Port: 80             │
        └──────────────────────┘      └──────────────────────┘

                     ┌──────────────┼──────────────┐
                     │                              │
                     ▼                              ▼
        ┌──────────────────────┐      ┌──────────────────────┐
        │ Backend Worker 1     │      │ Backend Worker 2     │
        │ Docker Container     │      │ Docker Container     │
        │ Port: 3000           │      │ Port: 3000           │
        └──────────────────────┘      └──────────────────────┘

```
<br>

## 🧩 Komponen Sistem
|Komponen|Fungsi|
|---|---|
|**Load Balancer (Nginx)**|Menerima seluruh traffic dari user dan mendistribusikan ke worker nodes menggunakan metode load balancing (round robin/least connections)|
|**Frontend Workers (2 VM)**|Menjalankan container aplikasi web (UI tiket konser)|
|**Backend Workers (2 VM)**|Menjalankan REST API (`/api/health`, `/api/tickets`)|
|**Docker**|Menjalankan aplikasi dalam container untuk konsistensi dan portabilitas|
|**Terraform**|Provisioning otomatis seluruh infrastruktur (VM, VNet, Subnet, NSG)|
|**Ansible**|Konfigurasi VM dan deployment container secara otomatis|
|**k6**|Load testing untuk menguji performa sistem hingga 1000 concurrent users|

<br>

## 🚡 Alur Request
1. User mengakses aplikasi melalui **Public IP Load Balancer**
2. Nginx menerima request dan meneruskan ke worker:
    - Request ke `/` → diarahkan ke **Frontend Workers**
    - Request ke `/api/*` → diarahkan ke **Backend Workers**
3. Backend memproses request dan mengembalikan response
4. Load balancer mengirim response kembali ke user

<br>

## 🔄 Mekanisme Load Balancing
Load balancer mendistribusikan request ke beberapa worker node secara otomatis:
- **Frontend** → dibagi ke 2 worker
- **Backend** → dibagi ke 2 worker
- Distribusi terbukti melalui variasi nilai `hostname` pada response API

Contoh:
```json
{ "hostname": "bc3c55f52889" }
{ "hostname": "7c1d9af83fff" }
```

<br>

## ☁️ Infrastruktur Cloud (Azure)
Sistem di-deploy pada **5 Virtual Machine (VM)** di Azure:

|Tipe VM|Jumlah|Fungsi|
|---|:---:|---|
|Load Balancer VM|1|Nginx reverse proxy|
|Frontend Worker VM|2|Menjalankan container frontend|
|Backend Worker VM|2|Menjalankan container backend|

**Semua VM berada dalam:**
- 1 Virtual Network (VNet)
- 1 Subnet (isolated network)
- Network Security Group (NSG) dengan rule:
  - Allow HTTP (80)
  - Allow HTTPS (443)
  - Allow SSH (22)

<br>

## 📝 Prinsip DevOps yang Diterapkan
1. **Infrastructure as Code (IaC)** → Terraform
2. **Configuration as Code (CaC)** → Ansible
3. **Containerization** → Docker
4. **High Availability** → Multi-worker + Load Balancer
5. **Scalability** → Horizontal scaling (tambah worker)
6. **Observability (basic)** → Logging + Load Testing (k6)

<br>

## 🎯 Tujuan Arsitektur
Arsitektur ini dirancang untuk:
1. Menghindari single point of failure
2. Menangani lonjakan trafik tinggi (hingga 1000 users)
3. Memastikan sistem tetap responsif dan stabil
4. Memudahkan deployment otomatis dan reproducible

<br>
