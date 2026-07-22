# Node Failure Mailer

Automatically monitor a blockchain node managed by `systemd` and send email notifications via SMTP whenever the node crashes or unexpectedly stops.

## Features

- Automatic node monitoring with `systemd`
- Automatic service restart
- Automatic failure detection
- Email notifications via SMTP
- Support multiple email recipients
- Portable project configuration using `.env`

---

# Requirements

| Software | Compatible Version        |
| -------- | ------------------------- |
| Ubuntu   | **22.04 LTS – 24.04 LTS** |
| Geth     | **1.13.x**                |
| systemd  | **250 – 255**             |
| Bash     | **5.x**                   |
| Git      | **2.40+**                 |
| msmtp    | **1.8.x**                 |
---

# Install Dependencies

Update package list.

```bash
sudo apt update
```

Install Geth (if not installed).

```bash
# Follow the official installation guide
https://geth.ethereum.org/docs/getting-started/installing-geth
```

Install msmtp.

```bash
sudo apt install msmtp
```

Verify installation.

```bash
geth version
```

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

# Environment Configuration

Copy the example environment file.

```bash
cp .env.example .env
```

Open the file.

```bash
nano .env
```

Example:

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

## Gmail App Password

To use Gmail SMTP, create an App Password.

Official Google guide:

https://support.google.com/accounts/answer/185833

---

# Install systemd Services

Copy the service files.

```bash
sudo cp systemd/geth-demo.service /etc/systemd/system/

sudo cp systemd/geth-alert@.service /etc/systemd/system/
```

Reload systemd.

```bash
sudo systemctl daemon-reload
```

Enable the service.

```bash
sudo systemctl enable geth-demo
```

Start the node.

```bash
sudo systemctl start geth-demo
```

Verify status.

```bash
sudo systemctl status geth-demo
```

---

# Verify Email Configuration

You can manually test the email script.

```bash
./scripts/send-email.sh test "SMTP configuration works."
```

---

# Simulate Node Failure

Find the running Geth process.

```bash
pidof geth
```

Kill the process.

```bash
sudo kill -9 $(pidof geth)
```

Expected behavior:

1. systemd detects the failure.
2. systemd executes the alert service.
3. Service information is collected.
4. An email notification is sent.
5. systemd automatically restarts the node.

---

# Check Logs

Node service.

```bash
journalctl -u geth-demo.service -n 100 --no-pager
```

Alert service.

```bash
journalctl -u geth-alert@geth-demo.service -n 100 --no-pager
```

---

# Project Structure

```text
.
├── config/
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
└── README.md
```

---

# Workflow

```text
Node Crash
     │
     ▼
systemd
     │
     ▼
OnFailure
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
systemd Restart
```
