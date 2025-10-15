#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date +%F_%H%M)"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 ; pwd -P)"
DUMP_DIR="$SCRIPT_DIR/../data/db_dumps"
mkdir -p "$DUMP_DIR"

# --- MariaDB / MySQL ---
if command -v mysqldump >/dev/null 2>&1 ; then
  MYSQL_USER="${MYSQL_USER:-backup}"
  MYSQL_PW="${MYSQL_PW:-change-me}"
  mysqldump --all-databases --single-transaction --quick -u "$MYSQL_USER" -p"$MYSQL_PW" \
    | gzip > "$DUMP_DIR/mariadb-${STAMP}.sql.gz"
fi

# --- PostgreSQL ---
if command -v pg_dumpall >/dev/null 2>&1 ; then
  pg_dumpall | gzip > "$DUMP_DIR/postgres-${STAMP}.sql.gz"
fi
