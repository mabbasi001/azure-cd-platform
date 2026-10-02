#!/usr/bin/env bash
# Download the most recent backup and restore it into a throwaway PostgreSQL
# container to prove the backup is usable. Exits non-zero if the restore or the
# sanity check fails.
set -euo pipefail

: "${BACKUP_STORAGE_ACCOUNT:?set BACKUP_STORAGE_ACCOUNT}"
BACKUP_CONTAINER="${BACKUP_CONTAINER:-pg-backups}"
PG_IMAGE="${PG_IMAGE:-postgres:15-alpine}"

tmp="$(mktemp -d)"
container="rw-restore-verify-$$"
cleanup() {
  docker rm -f "$container" >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT

echo "Finding the latest backup"
latest="$(az storage blob list \
  --account-name "$BACKUP_STORAGE_ACCOUNT" \
  --container-name "$BACKUP_CONTAINER" \
  --auth-mode login \
  --query "sort_by([].{name:name}, &name)[-1].name" -o tsv)"

if [ -z "$latest" ] || [ "$latest" = "None" ]; then
  echo "No backups found" >&2
  exit 1
fi
echo "Latest backup: ${latest}"

az storage blob download \
  --account-name "$BACKUP_STORAGE_ACCOUNT" \
  --container-name "$BACKUP_CONTAINER" \
  --name "$latest" \
  --file "$tmp/backup.sql.gz" \
  --auth-mode login

echo "Starting a throwaway PostgreSQL container"
docker run -d --name "$container" -e POSTGRES_PASSWORD=verify "$PG_IMAGE" >/dev/null
for _ in $(seq 1 30); do
  docker exec "$container" pg_isready -U postgres >/dev/null 2>&1 && break
  sleep 2
done

echo "Restoring backup"
gunzip -c "$tmp/backup.sql.gz" | docker exec -i "$container" psql -v ON_ERROR_STOP=1 -U postgres

table_count="$(docker exec "$container" psql -U postgres -tAc \
  "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';")"

echo "Restored public tables: ${table_count}"
if [ "$table_count" -lt 1 ]; then
  echo "Restore verification failed: no tables present" >&2
  exit 1
fi
echo "Restore verification passed"
