#!/usr/bin/env bash
set -euo pipefail

# Optional env vars before calling:
#   HC_URL       = https://hc.example.com/ping/UUID
#   APPRISE_URL  = http://apprise:8008/notify?tag=email,telegram

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 ; pwd -P)"
ROOT_DIR="$SCRIPT_DIR/.."

# 1) DB dump
bash "$ROOT_DIR/scripts/db_dump.sh"

# 2) Ensure repo is connected
set +e
docker exec kopia sh -lc 'kopia repo connect filesystem --path=/kopia-repo --password-file=/run/secrets/kopia_repo_password >/dev/null 2>&1 || true'
set -e

# 3) Retention policy (idempotent)
docker exec kopia sh -lc '
  kopia policy set /source --retention-annual 2 --retention-monthly 12 \
    --retention-weekly 4 --retention-daily 7 --retention-hourly 0 --keep-latest 5
'

# 4) Snapshots
set +e
docker exec kopia sh -lc '
  kopia snapshot create /source/docker --tags="class=docker" && \
  kopia snapshot create /source/etc   --tags="class=etc" && \
  kopia snapshot create /source/var_lib --tags="class=varlib" && \
  kopia snapshot create /source/home  --tags="class=home" && \
  kopia snapshot create /source/db_dumps --tags="class=dbdump"
'
STATUS=$?
set -e

# 5) Quick maintenance
docker exec kopia sh -lc 'kopia maintenance run --quick'

# 6) Notifications
if [ ${STATUS} -eq 0 ]; then
  [ -n "${HC_URL:-}" ] && curl -fsS -m 10 --retry 3 "$HC_URL" >/dev/null 2>&1 || true
  [ -n "${APPRISE_URL:-}" ] && curl -fsS -m 10 -X POST "$APPRISE_URL" \
     -d "title=Kopia backup" -d "body=Backup OK" >/dev/null 2>&1 || true
else
  [ -n "${HC_URL:-}" ] && curl -fsS -m 10 --retry 3 "$HC_URL/fail" >/dev/null 2>&1 || true
  [ -n "${APPRISE_URL:-}" ] && curl -fsS -m 10 -X POST "$APPRISE_URL" \
     -d "title=Kopia backup" -d "body=Backup FAILED" >/dev/null 2>&1 || true
  exit 1
fi
