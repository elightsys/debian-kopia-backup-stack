# Monthly Restore Drill

1. Ensure Kopia is running: `make up`
2. Execute: `make restore-drill`
3. Inspect files in `_restores/restore_YYYY-MM-DD/`
4. (Optional) gunzip one SQL dump and validate schema.
5. Wire this into systemd monthly timer if you want it hands‑off.
