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

## 🚀 Panduan Instalasi Cepat (1x Copas Langsung Run)

Pada server baru (fresh install), cukup **salin satu baris perintah ini** dan tempel di terminal:

```bash
curl -sSL https://raw.githubusercontent.com/gulbudin/erapor-smp-linux/main/quick_install.sh | bash
```

> **Atau alternatif (tanpa curl terlebih dahulu):**
> ```bash
> apt-get update -y && apt-get install -y git && rm -rf /var/www/eraporsmp && git clone https://github.com/gulbudin/erapor-smp-linux.git /var/www/eraporsmp && cd /var/www/eraporsmp && bash install_linux.sh
> ```

Perintah di atas akan otomatis menginstal git/curl, mengunduh repositori, memasang PHP 8.2, ionCube Loader, PostgreSQL, merestore database template, dan menyalakan Nginx.

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


---

## 🙏 Ucapan Terima Kasih & Apresiasi Khusus (Special Thanks & Dedication)

Apresiasi dan rasa terima kasih yang setinggi-tingginya kami haturkan kepada:

**Bapak I Nyoman Pasek, S.Pd., M.Pd.**  
*Pengembang Utama Aplikasi e-Rapor — Kementerian Pendidikan Dasar dan Menengah Republik Indonesia.*

Atas dedikasi tulus, kerja keras, dan karya luar biasa beliau dalam merancang serta mengembangkan ekosistem penilaian **e-Rapor Kurikulum Merdeka** yang telah memberikan manfaat besar bagi ratusan ribu sekolah, jutaan guru, dan peserta didik di seluruh penjuru Nusantara.

Paket migrasi Linux ini dihadirkan dengan rasa hormat penuh atas karya beliau, bertujuan untuk memperluas fleksibilitas penerapan e-Rapor agar dapat berjalan optimal, tangguh, dan efisien di atas server berbasis Linux.

## 📄 Lisensi & Kredit

- **Pengembang Asli**: Tim Pengembang Direktorat SMP, Kementerian Pendidikan Dasar dan Menengah RI.
- **Migrasi & Optimasi Linux**: Tim Pengembang [Edukasi Data Nusantara](https://edukasidata.id).
- Digunakan untuk kepentingan kemajuan pendidikan di Indonesia.
