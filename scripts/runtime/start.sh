#!/usr/bin/env bash
# Start the application tier (and optionally the runner VM).
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=scripts/runtime/common.sh
. ./common.sh
require_az

echo "Starting PostgreSQL ${POSTGRES_SERVER}"
az postgres flexible-server start --name "$POSTGRES_SERVER" --resource-group "$APP_RESOURCE_GROUP" 2>/dev/null || true

echo "Starting web apps"
az webapp start --name "$BACKEND_APP" --resource-group "$APP_RESOURCE_GROUP"
az webapp start --name "$FRONTEND_APP" --resource-group "$APP_RESOURCE_GROUP"

if [ "${INCLUDE_RUNNER:-false}" = "true" ]; then
  echo "Starting runner VM ${RUNNER_VM}"
  az vm start --name "$RUNNER_VM" --resource-group "$SHARED_RESOURCE_GROUP"
fi

echo "Start complete."
