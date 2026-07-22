🌐 Language: **English** | [Bahasa Indonesia](README.id.md)

# Node Failure Mailer

Node Failure Mailer is a simple project that monitors a blockchain node managed by `systemd` and automatically sends email notifications via SMTP whenever the node crashes or stops unexpectedly.

## Features

- Monitor blockchain nodes using `systemd`
- Automatically restart the node after failure
- Detect service failures using `OnFailure`
- Send email notifications via SMTP
- Support multiple email recipients
- Configure SMTP using a `.env` file
- Automatically install and configure `systemd` services

---

# Requirements

| Software | Supported Version |
|----------|-------------------|
| Ubuntu | **22.04 LTS – 24.04 LTS** |
| Geth | **1.13.x** |
| systemd | **250 – 255** |
| Bash | **5.x** |
| Git | **2.40+** |
| msmtp | **1.8.x** |

---

# Install Dependencies

Update the package list.

```bash
sudo apt update
```

## Install Geth

Add the official Ethereum repository.

```bash
sudo add-apt-repository -y ppa:ethereum/ethereum
```

Update the package list.

```bash
sudo apt update
```

Install Geth.

```bash
sudo apt install ethereum
```

Verify the installation.

```bash
geth version
```

Official Geth installation guide:

https://geth.ethereum.org/docs/getting-started/installing-geth

## Install msmtp

```bash
sudo apt install msmtp
```

Verify the installation.

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

Edit the configuration file.

```bash
nano .env
```

Example configuration.

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

If you are using Gmail SMTP, create an App Password first.

Official Google documentation:

https://support.google.com/accounts/answer/185833

---

# Security

Restrict permissions for executable scripts and sensitive files.

```bash
chmod +x install.sh
chmod +x scripts/*.sh

chmod 600 .env
```

Explanation:

- `chmod +x` grants execute permission to the installer and all project scripts.
- `.env` can only be read and modified by the file owner.

---

# Install systemd Services

Run the installer.

```bash
./install.sh
```

The installer automatically:

- Detects the current project directory.
- Detects the current Linux user.
- Installs the required `systemd` service files.
- Reloads the `systemd` daemon configuration.

---

# Start the Service

Enable the service to start automatically at boot.

```bash
sudo systemctl enable geth-demo.service
```

Start the service.

```bash
sudo systemctl start geth-demo.service
```

Check the service status.

```bash
sudo systemctl status geth-demo.service
```

---

# Verify Email Configuration

Send a test email.

```bash
./scripts/send-email.sh test "SMTP configuration works."
```

If the SMTP configuration is correct, the email will be delivered to every recipient listed in the `SMTP_TO` variable.

---

# Simulate a Node Failure

To test the monitoring and notification system, send a `SIGKILL` signal to the Geth service.

```bash
sudo systemctl kill -s SIGKILL geth-demo.service
```

Expected behavior:

1. `systemd` detects the service failure.
2. `systemd` starts `geth-alert@.service`.
3. `systemd-failure-email.sh` is executed.
4. `collect-service-info.sh` gathers service information.
5. `send-email.sh` sends an email notification.
6. `systemd` automatically restarts the Geth service.

---

# View Logs

View the Geth service logs.

```bash
sudo journalctl -u geth-demo.service -n 100 --no-pager
```

View the alert service logs.

```bash
sudo journalctl -u 'geth-alert@*' -n 100 --no-pager
```

---

# Project Structure

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

# Workflow

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
systemd Restarts the Service
```