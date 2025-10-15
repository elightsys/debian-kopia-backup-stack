#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 ; pwd -P)"
ROOT_DIR="$SCRIPT_DIR/.."
TEST_DIR="$ROOT_DIR/_restores/restore_$(date +%F)"
mkdir -p "$TEST_DIR"

# restore latest db_dumps snapshot inside container, then copy out
docker exec kopia sh -lc '
  LAST=$(kopia snapshots list /source/db_dumps --json | jq -r ".[0].id" )
  [ -n "$LAST" ] || (echo "No snapshots found" && exit 1)
  rm -rf /tmp/restore_test && mkdir -p /tmp/restore_test
  kopia restore --snapshot "$LAST" --target /tmp/restore_test
'

docker cp kopia:/tmp/restore_test "$TEST_DIR"

COUNT=$(find "$TEST_DIR/restore_test" -type f -name "*.sql.gz" | wc -l | tr -d " ")
echo "Found $COUNT dump files."

FIRST=$(find "$TEST_DIR/restore_test" -type f -name "*.sql.gz" | head -n1)
[ -n "$FIRST" ] && gzip -t "$FIRST"

echo "Restore drill OK into $TEST_DIR"
