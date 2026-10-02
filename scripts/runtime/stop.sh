#!/usr/bin/env bash
# Stop the application tier (and optionally the runner VM) to save cost.
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=scripts/runtime/common.sh
. ./common.sh
require_az

echo "Stopping web apps"
az webapp stop --name "$BACKEND_APP" --resource-group "$APP_RESOURCE_GROUP"
az webapp stop --name "$FRONTEND_APP" --resource-group "$APP_RESOURCE_GROUP"

echo "Stopping PostgreSQL ${POSTGRES_SERVER}"
az postgres flexible-server stop --name "$POSTGRES_SERVER" --resource-group "$APP_RESOURCE_GROUP" 2>/dev/null || true

if [ "${INCLUDE_RUNNER:-false}" = "true" ]; then
  echo "Deallocating runner VM ${RUNNER_VM}"
  az vm deallocate --name "$RUNNER_VM" --resource-group "$SHARED_RESOURCE_GROUP"
fi

echo "Stop complete."
