# Disaster recovery runbook

Region-level failover for the RealWorld platform. The design is **active-passive**:
the primary region serves all traffic; the secondary region is a warm standby with
a cross-region PostgreSQL read replica. Azure Front Door fails traffic over on a
failed health probe automatically; the database and its promotion are manual.

## Targets

- **RTO** (time to restore service): ~30 min, dominated by replica promotion.
- **RPO** (data loss window): seconds — asynchronous replica lag under normal load.

## Standing setup (both regions provisioned)

- `stacks/shared` deployed in each region (own VNet, Key Vault), non-overlapping
  `address_space`.
- Primary ACR on Premium with `acr_georeplication_locations` including the secondary.
- Primary app stack: `postgres_geo_redundant_backup = true`.
- Secondary app stack (own workspace): `database_role = replica`,
  `replica_source_server_id` = primary `postgres_server_id` output,
  `replica_admin_password` = primary admin password (from the primary Key Vault).
- `stacks/frontdoor` with both regions' hostnames in the origin lists, primary first.

## Normal operation

Front Door routes everything to the primary (priority 1). The secondary web/API
apps run (min 2 instances) but take no traffic; the replica streams from the primary.

## Failover (primary region lost)

1. **Confirm** the primary is actually down (Front Door origin health red, App
   Insights availability failing) and not a transient blip.
2. **Promote the replica** to a standalone writable server:
   ```bash
   az postgres flexible-server replica promote \
     --resource-group rg-rw-prod --name psql-rw-prod-e8f-eus2
   ```
3. **Point the secondary app at the promoted server.** Its `database-url` secret
   already resolves to the replica's FQDN; restart the API app so it reconnects:
   ```bash
   az webapp restart --name app-rw-prod-api-e8f-eus2 --resource-group rg-rw-prod
   ```
4. **Shift traffic.** Front Door will already be serving the secondary (priority 2)
   once the primary origins are unhealthy. To force it, disable the primary origins:
   ```bash
   az afd origin update --profile-name afd-rw-global --resource-group rg-rw-global \
     --origin-group-name og-api --origin-name origin-api-0 --enabled-state Disabled
   ```
5. **Verify** `https://<frontdoor-endpoint>/api/tags` and the web app load.

## Failback (primary region restored)

1. Rebuild the primary app stack; re-create a read replica, this time sourced from
   the (now primary) secondary server.
2. Let it catch up, then schedule a maintenance window, promote the primary back,
   and re-enable the primary origins in Front Door.

## Rehearsal

Run a game day quarterly: disable the primary origins in Front Door, promote a
throwaway replica, measure actual RTO, and update this runbook with what broke.
