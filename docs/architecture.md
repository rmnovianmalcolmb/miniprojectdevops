# Architecture Overview

## Diagram (Mermaid)

```mermaid
graph TD
    User --> LB[Load Balancer (Nginx)]
    LB --> W1[Worker 1]
    LB --> W2[Worker 2]

    W1 --> FE1[Frontend Container]
    W1 --> BE1[Backend Container]

    W2 --> FE2[Frontend Container]
    W2 --> BE2[Backend Container]
```

## Penjelasan

* User mengakses aplikasi melalui Load Balancer
* Nginx mendistribusikan traffic ke worker menggunakan metode `least_conn`
* Setiap worker menjalankan:

  * Frontend (port 8080)
  * Backend (port 3000)

## Alur Request

1. User request ke `/`
2. LB forward ke frontend container
3. Request `/api` diarahkan ke backend
4. Backend merespon data tiket

## Keunggulan Arsitektur

* Scalability (bisa tambah worker)
* High availability
* Separation of concern
