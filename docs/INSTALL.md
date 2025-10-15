# Install & Run

## 1) Prerequisites (Debian 12)
```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin jq curl
```

## 2) Clone & prepare
```bash
git clone https://github.com/<your-org>/debian-kopia-backup-stack.git
cd debian-kopia-backup-stack
cp -r secrets.example secrets
cp .env.example .env
# edit secrets/* and .env
```

## 3) Service startup
```bash
make up
# open http://<server>:51515 and login
```

## 4) First backup
```bash
make backup
```

## 5) Schedule with systemd (host)
Create `/etc/systemd/system/kopia-backup.service`:
```ini
[Unit]
Description=Nightly Kopia Backup (with DB dumps)
[Service]
Type=oneshot
Environment=HC_URL=
Environment=APPRISE_URL=
ExecStart=/usr/bin/env bash /path/to/debian-kopia-backup-stack/scripts/backup.sh
User=root
```
Create `/etc/systemd/system/kopia-backup.timer`:
```ini
[Unit]
Description=Run Kopia Backup nightly at 02:30
[Timer]
OnCalendar=*-*-* 02:30:00
Persistent=true
[Install]
WantedBy=timers.target
```
Then:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now kopia-backup.timer
```
