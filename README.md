# e-Rapor SMP Kurikulum Merdeka (Linux Server Edition)

[![PHP Version](https://img.shields.io/badge/PHP-8.2-777BB4?style=flat&logo=php&logoColor=white)](https://php.net)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2F15%2F16-336791?style=flat&logo=postgresql&logoColor=white)](https://postgresql.org)
[![Nginx](https://img.shields.io/badge/Nginx-Web--Server-009639?style=flat&logo=nginx&logoColor=white)](https://nginx.org)
[![ionCube](https://img.shields.io/badge/ionCube-v15.5+-orange?style=flat)](https://ioncube.com)
[![License](https://img.shields.io/badge/License-Kemendikdasmen-blue.svg)](https://kemdikbud.go.id)

Aplikasi resmi **e-Rapor Kurikulum Merdeka Jenjang SMP** yang telah dimigrasi dan dioptimalkan secara penuh untuk lingkungan **Server Linux (Ubuntu / Debian)**.

Paket ini dirancang agar siap dipasang pada server baru (fresh install) baik server fisik, VPS lokal, Proxmox VM, maupun cloud server secara mandiri atau terintegrasi dengan portal manajemen.

---

## ⚡ Fitur & Keunggulan Versi Linux

1. **Native Linux High-Performance**: Berjalan di atas Nginx + PHP 8.2 FPM + PostgreSQL 16 tanpa memerlukan emulasi Windows.
2. **Automated One-Click Installer**: Dilengkapi skrip instalasi otomatis (`install_linux.sh`) yang mengonfigurasi PHP 8.2, ionCube Loader, PostgreSQL, database dump, dan Nginx secara instan.
3. **Dapodik URL Sanitizer Patch**: Mengatasi kendala koneksi Dapodik ketika operator menyertakan awalan `http://` atau port secara manual pada input IP Server Dapodik.
4. **Multi-Tenancy & Subdomain Ready**: Mendukung isolasi database per sekolah jika digunakan dalam arsitektur SaaS / Cloud Sekolah.
5. **Memory & I/O Efficient**: Jauh lebih hemat resource (RAM ~250MB saat idle) dibandingkan menjalankan aplikasi di Windows Server.

---

## 🖥️ Kebutuhan Sistem Minimum

| Komponen | Spesifikasi Minimum | Rekomendasi |
| :--- | :--- | :--- |
| **Sistem Operasi** | Ubuntu 20.04 / 22.04 / 24.04 LTS atau Debian 11 / 12 | Ubuntu 22.04 / 24.04 LTS (64-bit) |
| **Processor (CPU)** | 1 Core (x86_64) | 2 Core atau lebih |
| **Memory (RAM)** | 1 GB RAM | 2 GB - 4 GB RAM |
| **Penyimpanan (Storage)** | 10 GB SSD | 20 GB SSD |
| **Web Server** | Nginx | Nginx 1.18+ |
| **Database** | PostgreSQL 14 / 15 / 16 | PostgreSQL 16 |
| **PHP Runtime** | PHP 8.2 FPM | PHP 8.2 FPM + ionCube Loader 15.5+ |

---

## 🚀 Panduan Instalasi Cepat (Server Baru / Fresh Install)

Cukup clone repositori ini ke server Linux Anda dan jalankan skrip instalasi:

```bash
# 1. Masuk sebagai root
sudo su -

# 2. Install Git (wajib untuk server baru yang belum ada git)
apt update -y && apt install -y git

# 3. Clone repositori ke direktori /var/www/eraporsmp
git clone https://github.com/gulbudin/erapor-smp-linux.git /var/www/eraporsmp

# 4. Masuk ke direktori dan beri izin eksekusi
cd /var/www/eraporsmp
chmod +x install_linux.sh

# 5. Jalankan instalasi otomatis
bash install_linux.sh
```

Skrip akan secara otomatis:
- Memasang paket `nginx`, `postgresql`, `php8.2` dan modul lengkapnya.
- Mengunduh dan mengonfigurasi modul resmi **ionCube Loader Linux 8.2**.
- Membuat database `dbraporkemdikbud25` dan merestore skema template e-Rapor.
- Mengonfigurasi Virtual Host Nginx pada Port **8534**.
- Menyiapkan hak akses `www-data` dan folder `writable`.

Setelah proses selesai, buka browser Anda dan akses:
```
http://IP-SERVER-ANDA:8534
```

---

## 📁 Struktur Repositori

```
erapor-smp-linux/
├── app/                        # Direktori aplikasi CodeIgniter 4
├── public/                     # Document root Nginx (index.php, CSS, JS, assets)
├── vendor/                     # Dependensi Composer
├── writable/                   # Folder cache, sesi, dan log runtime
├── database/
│   └── database_template.sql   # Template database PostgreSQL siap import
├── .encapp                     # Konfigurasi port web & multi-tenant
├── .env                        # Konfigurasi environment CodeIgniter
├── .gitignore                  # Filter berkas sesi dan cache runtime
├── composer.json               # Manifest dependensi PHP
├── install_linux.sh            # Skrip otomatisasi instalasi Linux
└── README.md                   # Panduan dokumentasi lengkap
```

---

## 🔧 Konfigurasi Default

- **Port Web Nginx**: `8534`
- **Database Engine**: PostgreSQL 5432
- **Nama Database Default**: `dbraporkemdikbud25`
- **User Database**: `postgres`
- **Password Database**: `secrets_deveraporsd2025*#rsp`
- **Berkas Konfigurasi Nginx**: `/etc/nginx/sites-available/eraporsmp`

---

## 🔗 Integrasi Dapodik

1. Pastikan server e-Rapor dan server Dapodik saling terhubung dalam satu jaringan (LAN/VPN) atau IP publik server Dapodik dapat diakses dari server e-Rapor.
2. Di aplikasi Dapodik, tambahkan Web Service untuk e-Rapor:
   - Nama Koneksi: `e-Rapor SMP`
   - IP Address Server e-Rapor: Masukkan IP Server Linux e-Rapor Anda
3. Salin **Key Web Service** (Token) dan **NPSN** sekolah ke menu Pengaturan / Ambil Dapodik pada e-Rapor.
4. Klik **Tarik Data** untuk menyinkronkan data guru, siswa, dan rombel.

---

## 📄 Lisensi & Kredit

- **Pengembang Asli**: Tim Pengembang Direktorat SMP, Kementerian Pendidikan Dasar dan Menengah RI.
- **Migrasi & Optimasi Linux**: Tim Pengembang [Edukasi Data Nusantara](https://edukasidata.id).
- Digunakan untuk kepentingan kemajuan pendidikan di Indonesia.
