# ReaR (Relax-and-Recover) — Bare-metal recovery

Install:
```bash
sudo apt update
sudo apt install -y rear isolinux syslinux
```

Config `/etc/rear/local.conf`:
```conf
OUTPUT=ISO
OUTPUT_URL=file:///var/backups/rear
BACKUP=NETFS
BACKUP_URL=file:///var/backups/rear/data
EXCLUDE_MOUNTPOINTS=( '/var/backups' )
NETFS_KEEP_OLD_BACKUP_COPY=yes
```

Initial run:
```bash
sudo rear mkrescue
sudo rear mkbackup
```

Schedule weekly:
```ini
# /etc/systemd/system/rear-backup.service
[Unit]
Description=ReaR bare-metal backup
[Service]
Type=oneshot
ExecStart=/usr/sbin/rear mkbackup
User=root
```
```ini
# /etc/systemd/system/rear-backup.timer
[Unit]
Description=Weekly ReaR backup
[Timer]
OnCalendar=Sun *-*-* 04:00:00
Persistent=true
[Install]
WantedBy=timers.target
```
Enable:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now rear-backup.timer
```
