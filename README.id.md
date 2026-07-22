🌐 Bahasa: **Indonesia** | [English](README.md)

# Node Failure Mailer

Node Failure Mailer adalah proyek sederhana untuk memonitor node blockchain yang dikelola oleh `systemd` dan secara otomatis mengirimkan notifikasi email melalui SMTP ketika node mengalami kegagalan (crash) atau berhenti secara tidak normal.

## Fitur

- Monitoring node blockchain menggunakan `systemd`
- Restart otomatis ketika service gagal
- Deteksi kegagalan menggunakan `OnFailure`
- Notifikasi email otomatis melalui SMTP
- Mendukung banyak penerima email
- Konfigurasi SMTP menggunakan file `.env`
- Installer otomatis untuk membuat service `systemd`

---

# Persyaratan

| Software | Versi yang Didukung |
|----------|---------------------|
| Ubuntu | **22.04 LTS – 24.04 LTS** |
| Geth | **1.13.x** |
| systemd | **250 – 255** |
| Bash | **5.x** |
| Git | **2.40+** |
| msmtp | **1.8.x** |

---

# Instalasi Dependensi

Perbarui daftar paket.

```bash
sudo apt update
```

## Install Geth

Tambahkan repository resmi Ethereum.

```bash
sudo add-apt-repository -y ppa:ethereum/ethereum
```

Perbarui daftar paket.

```bash
sudo apt update
```

Install Geth.

```bash
sudo apt install ethereum
```

Pastikan instalasi berhasil.

```bash
geth version
```

Panduan resmi Geth:

https://geth.ethereum.org/docs/getting-started/installing-geth

## Install msmtp

```bash
sudo apt install msmtp
```

Pastikan instalasi berhasil.

```bash
msmtp --version
```

---

# Clone Repository

```bash
git clone https://github.com/zakoraa/node-failure-mailer.git

cd node-failure-mailer
```

---

# Konfigurasi Environment

Salin file konfigurasi.

```bash
cp .env.example .env
```

Edit file.

```bash
nano .env
```

Contoh konfigurasi.

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587

SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=YOUR_APP_PASSWORD

SMTP_FROM=your-email@gmail.com

SMTP_TO=admin1@gmail.com,admin2@gmail.com

SMTP_TLS=on
SMTP_STARTTLS=on
```

---

# Gmail App Password

Jika menggunakan Gmail SMTP, buat terlebih dahulu App Password.

Panduan resmi Google:

https://support.google.com/accounts/answer/185833

---

# Keamanan

Batasi hak akses file yang berisi informasi sensitif dan script yang akan dijalankan.

```bash
chmod +x install.sh
chmod +x scripts/*.sh

chmod 600 .env
chmod 600 data/password.txt
chmod 700 data
```

Penjelasan:

- `chmod +x` memberikan izin eksekusi pada installer dan seluruh script.
- `.env` hanya dapat dibaca dan diubah oleh pemilik file.
- `data/password.txt` hanya dapat dibaca oleh pemilik file.
- Folder `data` hanya dapat diakses oleh pemilik.

---

# Instalasi Service systemd

Jalankan installer.

```bash
./install.sh
```

Installer akan secara otomatis:

- Menyesuaikan lokasi project sesuai direktori saat ini.
- Menyesuaikan username Linux yang sedang digunakan.
- Membuat file service pada `/etc/systemd/system`.
- Melakukan reload konfigurasi `systemd`.

---

# Menjalankan Service

Aktifkan service agar otomatis berjalan saat boot.

```bash
sudo systemctl enable geth-demo.service
```

Jalankan service.

```bash
sudo systemctl start geth-demo.service
```

Periksa status service.

```bash
sudo systemctl status geth-demo.service
```

---

# Verifikasi Konfigurasi Email

Kirim email percobaan.

```bash
./scripts/send-email.sh test "SMTP configuration works."
```

Apabila konfigurasi SMTP benar, email akan diterima oleh seluruh alamat yang terdapat pada variabel `SMTP_TO`.

---

# Simulasi Node Crash

Untuk menguji mekanisme monitoring dan notifikasi, kirim sinyal `SIGKILL` ke service Geth.

```bash
sudo systemctl kill -s SIGKILL geth-demo.service
```

Perilaku yang diharapkan:

1. `systemd` mendeteksi bahwa service mengalami kegagalan.
2. `systemd` menjalankan `geth-alert@.service`.
3. `systemd-failure-email.sh` dijalankan.
4. `collect-service-info.sh` mengumpulkan informasi service.
5. `send-email.sh` mengirim email notifikasi.
6. `systemd` otomatis menjalankan kembali service Geth.

---

# Melihat Log

Log service Geth.

```bash
sudo journalctl -u geth-demo.service -n 100 --no-pager
```

Log service notifikasi.

```bash
sudo journalctl -u 'geth-alert@*' -n 100 --no-pager
```

---

# Struktur Project

```text
.
├── data/
├── scripts/
│   ├── collect-service-info.sh
│   ├── load-env.sh
│   ├── send-email.sh
│   └── systemd-failure-email.sh
├── systemd/
│   ├── geth-demo.service
│   └── geth-alert@.service
├── .env.example
├── genesis.json
├── install.sh
└── README.md
```

---

# Alur Kerja

```text
Geth Node Crash
        │
        ▼
systemd
        │
        ▼
OnFailure=geth-alert@%n
        │
        ▼
geth-alert@.service
        │
        ▼
systemd-failure-email.sh
        │
        ▼
collect-service-info.sh
        │
        ▼
send-email.sh
        │
        ▼
SMTP Server
        │
        ▼
Email Notification
        │
        ▼
systemd Restart Service
```