# 🎟️ Concert Ticketing System - Backend API

Backend service untuk sistem pemesanan tiket konser yang dibangun menggunakan **Node.js** dan **Express.js**, serta dikemas dengan **Docker** untuk memastikan portabilitas, konsistensi, dan keamanan.

---

##  Installation & Running

###  Run with Docker (Recommended)

```bash
cd backend

# Build image
docker build -t concert-backend:latest .

# Run container
docker run -d -p 3000:3000 --name backend-container concert-backend:latest
````

---

###  Run without Docker

```bash
npm install
npm start
```

---

##  API Endpoints

Base URL:

```
http://localhost:3000
```

###  Health Check

```
GET /
```

Response:

```json
{
  "status": "OK",
  "message": "Server is running"
}
```

---

###  Get All Concerts

```
GET /api/concerts
```

Response:

```json
[
  {
    "id": 1,
    "name": "Coldplay Live",
    "location": "Jakarta",
    "date": "2026-08-12"
  },
  {
    "id": 2,
    "name": "Taylor Swift Tour",
    "location": "Singapore",
    "date": "2026-09-01"
  }
]
```

---

##  Docker Configuration

### Dockerfile (Summary)

* Menggunakan base image ringan
* Install dependency production only
* Expose port 3000

---

##  Security & Vulnerability Scanning

Project ini menggunakan **Docker Scout** untuk memastikan image bebas dari vulnerability berbahaya sebelum digunakan di production.

---

### 🔍 Run Security Scan

```bash
docker scout cves concert-backend:latest --local
```

---

###  Scan Result Summary

| Severity | Count |
| -------- | ----- |
| Critical | 0     |
| High     | 1     |
| Medium   | 3     |
| Low      | 0     |

> *Masalah hanya dari base image, bukan kode aplikasi dan tidak berdampak kritis.

---

###  CVE Mitigation Strategy

Beberapa langkah yang dilakukan untuk mengatasi potensi CVEs:

#### 1. Dependency Upgrade

* Upgrade ke:

  * `express@4.21.0`
* Mengatasi vulnerability lama seperti:

  * body-parser issue
  * outdated middleware risk

---

#### 2. Override Transitive Dependencies

Menggunakan fitur `overrides` di `package.json`:

```json
"overrides": {
  "picomatch": "^2.3.1",
  "brace-expansion": "^2.0.1"
}
```

Tujuan:

* Memaksa dependency turunan menggunakan versi aman
* Mencegah eksploitasi CVE pada dependency tidak langsung

---

#### 3. Minimal Attack Surface

* Menggunakan base image minimal
* Tidak menyertakan devDependencies di production
* Hanya expose port yang diperlukan

---

#### 4. Secure Container Practices

* Tidak menjalankan container sebagai root (recommended improvement)
* Menghindari hardcoded secrets
* Menggunakan `.dockerignore`

---
##  Future Improvements

* Authentication & Authorization (JWT)
* Database integration (PostgreSQL / MongoDB)
* Rate limiting & API protection
* CI/CD pipeline + auto security scan
