# Backups

Two layers protect the database:

1. **Managed automated backups** — the PostgreSQL flexible server keeps daily backups with
   point-in-time restore (`backup_retention_days` in the Terraform module).
2. **Logical dumps** — `pg_backup.sh` runs `pg_dump` daily (via the `backup` GitHub workflow) and
   stores a gzipped dump in the `pg-backups` container of the backup storage account. A lifecycle
   rule expires dumps after 30 days.

The database is on a private network, so both scripts run on the self-hosted runner (inside the
VNet) and authenticate with Azure AD — no storage keys or passwords on disk.

## Scripts

- `pg_backup.sh` — reads the DB URL from Key Vault, dumps via a `postgres` container, uploads to
  Blob. Env: `KEY_VAULT_NAME`, `BACKUP_STORAGE_ACCOUNT`, optional `BACKUP_CONTAINER`.
- `pg_restore_verify.sh` — downloads the latest dump, restores it into a throwaway `postgres`
  container, and asserts tables exist. Proves the backups are actually restorable.

Run on a schedule via `.github/workflows/backup.yml` (daily backup + restore verification).
