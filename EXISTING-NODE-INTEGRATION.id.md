🌐 Bahasa: **Indonesia** | [English](EXISTING-NODE-INTEGRATION.md)

# Integrasi Node Failure Mailer ke Node Geth yang Sudah Ada

Dokumen ini menjelaskan cara mengintegrasikan fitur notifikasi email dari **Node Failure Mailer** ke project node Geth yang sudah ada. Dengan mengikuti panduan ini, node akan secara otomatis mengirim email ketika service mengalami kegagalan (crash) dan dijalankan kembali oleh `systemd`.

---

# Prasyarat

Pastikan node Geth telah memenuhi persyaratan berikut.

- Menggunakan `systemd` sebagai service manager.
- Service Geth sudah berjalan dengan normal.
- `msmtp` telah terpasang dan dikonfigurasi.

Pastikan service dapat diakses menggunakan `systemctl`.

```bash
sudo systemctl status geth.service
```

---

# File yang Perlu Disalin

Salin file berikut dari repository **Node Failure Mailer** ke project node Anda.

```text
scripts/
├── collect-service-info.sh
├── load-env.sh
├── send-email.sh
└── systemd-failure-email.sh

systemd/
└── geth-alert@.service

.env.example
```

Contoh struktur project setelah integrasi.

```text
my-node-project/
├── data/
├── scripts/
│   ├── start-node.sh
│   ├── stop-node.sh
│   ├── collect-service-info.sh
│   ├── load-env.sh
│   ├── send-email.sh
│   └── systemd-failure-email.sh
├── systemd/
│   ├── geth.service
│   └── geth-alert@.service
├── .env
└── ...
```

---

# Fungsi Setiap File

| File | Fungsi |
|------|--------|
| `.env.example` | Template konfigurasi SMTP dan penerima email. |
| `collect-service-info.sh` | Mengumpulkan informasi service yang mengalami kegagalan. |
| `load-env.sh` | Memuat konfigurasi SMTP dari file `.env`. |
| `send-email.sh` | Mengirim email notifikasi melalui SMTP. |
| `systemd-failure-email.sh` | Script utama yang dijalankan oleh `systemd` ketika service gagal. |
| `geth-alert@.service` | Service template `systemd` yang dipanggil melalui mekanisme `OnFailure`. |

---

# Konfigurasi Environment

Salin file konfigurasi.

```bash
cp .env.example .env
```

Edit konfigurasi SMTP.

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

Jika menggunakan Gmail SMTP, buat App Password terlebih dahulu.

Panduan resmi Google.

https://support.google.com/accounts/answer/185833

---

# Hak Akses File

Berikan izin eksekusi pada seluruh script.

```bash
chmod +x scripts/*.sh
```

Batasi hak akses file konfigurasi.

```bash
chmod 600 .env
```

---

# Menambahkan Service Alert

Salin service alert ke direktori systemd.

```bash
sudo cp systemd/geth-alert@.service /etc/systemd/system/
```

Direktori `/etc/systemd/system` merupakan lokasi standar untuk service yang dibuat oleh administrator.

---

# Menyesuaikan Lokasi Project

Edit file service yang telah disalin.

```bash
sudo nano /etc/systemd/system/geth-alert@.service
```

Ubah bagian berikut.

```ini
ExecStart=__PROJECT_DIR__/scripts/systemd-failure-email.sh %i
```

Sesuaikan dengan lokasi project Anda.

Contoh apabila project berada pada:

```text
/home/ubuntu/my-node-project
```

maka ubah menjadi.

```ini
ExecStart=/home/ubuntu/my-node-project/scripts/systemd-failure-email.sh %i
```

Contoh lain apabila project berada pada:

```text
/opt/blockchain/geth-node
```

maka ubah menjadi.

```ini
ExecStart=/opt/blockchain/geth-node/scripts/systemd-failure-email.sh %i
```

---

# Menambahkan OnFailure ke Service Geth

Edit service Geth yang sudah ada.

```bash
sudo systemctl edit --full geth.service
```

Tambahkan konfigurasi berikut pada bagian `[Unit]`.

```ini
OnFailure=geth-alert@%n
```

Contoh.

```ini
[Unit]
Description=Ethereum Geth Node
After=network-online.target
Wants=network-online.target

OnFailure=geth-alert@%n
```

Mekanisme ini akan menjalankan `geth-alert@.service` setiap kali service Geth mengalami kegagalan.

---

# Reload Konfigurasi systemd

Reload konfigurasi systemd.

```bash
sudo systemctl daemon-reload
```

Restart service Geth.

```bash
sudo systemctl restart geth.service
```

Pastikan service berjalan normal.

```bash
sudo systemctl status geth.service
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
sudo systemctl kill -s SIGKILL geth.service
```

Perilaku yang diharapkan.

1. `systemd` mendeteksi bahwa service mengalami kegagalan.
2. `systemd` menjalankan `geth-alert@.service`.
3. `systemd-failure-email.sh` dijalankan.
4. `collect-service-info.sh` mengumpulkan informasi service.
5. `send-email.sh` mengirim email notifikasi.
6. `systemd` menjalankan kembali service Geth.

---

# Melihat Log

Log service Geth.

```bash
sudo journalctl -u geth.service -n 100 --no-pager
```

Log service alert.

```bash
sudo journalctl -u 'geth-alert@*' -n 100 --no-pager
```

---

# Alur Kerja

```text
Existing Geth Service
        │
        ▼
Node Crash
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
systemd Restarts the Service
```