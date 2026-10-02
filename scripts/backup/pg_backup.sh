#!/usr/bin/env bash
# Dump the application database and upload a gzipped backup to Blob storage.
# Expects: az CLI already authenticated, Docker available, and the caller to
# hold "Key Vault Secrets User" and "Storage Blob Data Contributor".
set -euo pipefail

: "${KEY_VAULT_NAME:?set KEY_VAULT_NAME}"
: "${BACKUP_STORAGE_ACCOUNT:?set BACKUP_STORAGE_ACCOUNT}"
BACKUP_CONTAINER="${BACKUP_CONTAINER:-pg-backups}"
DB_SECRET_NAME="${DB_SECRET_NAME:-database-url}"
PG_IMAGE="${PG_IMAGE:-postgres:15-alpine}"

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
dump_file="conduit-${timestamp}.sql.gz"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Reading database URL from Key Vault ${KEY_VAULT_NAME}"
database_url="$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "$DB_SECRET_NAME" --query value -o tsv)"

echo "Dumping database"
docker run --rm --network host -e PGURL="$database_url" "$PG_IMAGE" \
  sh -c 'pg_dump "$PGURL"' | gzip >"$tmp/$dump_file"

echo "Ensuring container ${BACKUP_CONTAINER} exists"
az storage container create \
  --account-name "$BACKUP_STORAGE_ACCOUNT" \
  --name "$BACKUP_CONTAINER" \
  --auth-mode login \
  --output none

echo "Uploading ${dump_file}"
az storage blob upload \
  --account-name "$BACKUP_STORAGE_ACCOUNT" \
  --container-name "$BACKUP_CONTAINER" \
  --name "$dump_file" \
  --file "$tmp/$dump_file" \
  --auth-mode login \
  --overwrite false

echo "Backup complete: ${BACKUP_STORAGE_ACCOUNT}/${BACKUP_CONTAINER}/${dump_file}"
