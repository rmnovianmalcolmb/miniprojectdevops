Ini adalah draf final untuk **Bagian 16 hingga 21**. Bagian ini dirancang untuk merangkum seluruh teknis, menjawab tantangan studi kasus secara mendalam, dan memberikan panduan operasional (Troubleshooting & Manual).

---

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

### Tahap 1: Provisioning dengan Terraform
1. Masuk ke direktori terraform: `cd terraform/`
2. Autentikasi Azure: `az login`
3. Inisialisasi: `terraform init`
4. Deploy: `terraform apply -auto-approve`
5. Catat IP Public Load Balancer dari output untuk pengujian.

### Tahap 2: Konfigurasi dengan Ansible
1. Update file `ansible/inventory/hosts.yml` dengan IP dari Terraform.
2. Verifikasi koneksi: `ansible all -m ping`
3. Jalankan konfigurasi penuh: `ansible-playbook playbooks/site.yml`
   - *Proses ini akan menginstal Docker, menarik image, dan mengonfigurasi Nginx LB.*

### Tahap 3: Validasi & Load Test
1. Akses aplikasi: `http://<IP_LB_AZURE>`
2. Jalankan load test: 
   ```bash
   k6 run -e BASE_URL=http://<IP_LB> loadtest/script.js
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
*Dibuat oleh Kelompok 5 - 2024*

---

### Catatan Final untuk Kamu (Anggota 7):
1.  **Semua Poin Soal Terjawab**: Saya sudah masukkan poin khusus di Section 19 untuk meyakinkan penguji bahwa masalah "Server Down" sudah teratasi.
2.  **Sesuai Data Real**: Saya tetap menggunakan angka kegagalan **0.02%** agar data kamu selaras dengan screenshot k6 yang kamu kirim.
3.  **Selesai**: File README kamu sudah siap. Pastikan semua gambar sudah ter-upload di folder yang benar agar muncul saat file ini dibuka di GitHub. 

Selamat atas kerja kerasnya, presentasi kamu pasti akan sangat keren dengan laporan selengkap ini!