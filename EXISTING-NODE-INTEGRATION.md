🌐 Language: **English** | [Bahasa Indonesia](EXISTING-NODE-INTEGRATION.id.md)

# Integrating Node Failure Mailer into an Existing Geth Node

This document explains how to integrate the email notification feature from **Node Failure Mailer** into an existing Geth node project. After completing this guide, your node will automatically send email notifications whenever the service crashes and is restarted by `systemd`.

---

# Prerequisites

Ensure that your Geth node meets the following requirements.

- Uses `systemd` as the service manager.
- The Geth service is already running correctly.
- `msmtp` is installed and configured.

Verify that the service is accessible using `systemctl`.

```bash
sudo systemctl status geth.service
```

---

# Files to Copy

Copy the following files from the **Node Failure Mailer** repository into your existing node project.

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

Example project structure after integration.

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

# File Descriptions

| File | Description |
|------|-------------|
| `.env.example` | Template for SMTP configuration and email recipients. |
| `collect-service-info.sh` | Collects information about the failed service. |
| `load-env.sh` | Loads SMTP configuration from the `.env` file. |
| `send-email.sh` | Sends email notifications via SMTP. |
| `systemd-failure-email.sh` | Main script executed by `systemd` when the service fails. |
| `geth-alert@.service` | `systemd` service template triggered through the `OnFailure` mechanism. |

---

# Environment Configuration

Copy the example configuration file.

```bash
cp .env.example .env
```

Edit the SMTP configuration.

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

# File Permissions

Grant execute permission to all scripts.

```bash
chmod +x scripts/*.sh
```

Restrict access to the configuration file.

```bash
chmod 600 .env
```

---

# Install the Alert Service

Copy the alert service to the systemd service directory.

```bash
sudo cp systemd/geth-alert@.service /etc/systemd/system/
```

The `/etc/systemd/system` directory is the standard location for administrator-managed `systemd` service files.

---

# Configure the Project Path

Edit the copied service file.

```bash
sudo nano /etc/systemd/system/geth-alert@.service
```

Replace the following line.

```ini
ExecStart=__PROJECT_DIR__/scripts/systemd-failure-email.sh %i
```

Update it to match the location of your project.

For example, if your project is located at:

```text
/home/ubuntu/my-node-project
```

Change it to:

```ini
ExecStart=/home/ubuntu/my-node-project/scripts/systemd-failure-email.sh %i
```

Another example, if your project is located at:

```text
/opt/blockchain/geth-node
```

Change it to:

```ini
ExecStart=/opt/blockchain/geth-node/scripts/systemd-failure-email.sh %i
```

---

# Add OnFailure to the Geth Service

Edit your existing Geth service.

```bash
sudo systemctl edit --full geth.service
```

Add the following configuration under the `[Unit]` section.

```ini
OnFailure=geth-alert@%n
```

Example.

```ini
[Unit]
Description=Ethereum Geth Node
After=network-online.target
Wants=network-online.target

OnFailure=geth-alert@%n
```

This configuration ensures that `geth-alert@.service` is executed whenever the Geth service fails.

---

# Reload systemd Configuration

Reload the systemd configuration.

```bash
sudo systemctl daemon-reload
```

Restart the Geth service.

```bash
sudo systemctl restart geth.service
```

Verify that the service is running correctly.

```bash
sudo systemctl status geth.service
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

To test the monitoring and notification mechanism, send a `SIGKILL` signal to the Geth service.

```bash
sudo systemctl kill -s SIGKILL geth.service
```

Expected behavior.

1. `systemd` detects that the service has failed.
2. `systemd` starts `geth-alert@.service`.
3. `systemd-failure-email.sh` is executed.
4. `collect-service-info.sh` gathers information about the failed service.
5. `send-email.sh` sends an email notification.
6. `systemd` automatically restarts the Geth service.

---

# View Logs

View the Geth service logs.

```bash
sudo journalctl -u geth.service -n 100 --no-pager
```

View the alert service logs.

```bash
sudo journalctl -u 'geth-alert@*' -n 100 --no-pager
```

---

# Workflow

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