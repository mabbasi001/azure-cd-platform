#!/usr/bin/env bash
# Shared defaults for the runtime scripts. Override any value via the environment.
set -euo pipefail

APP_RESOURCE_GROUP="${APP_RESOURCE_GROUP:-rg-rw-dev}"
SHARED_RESOURCE_GROUP="${SHARED_RESOURCE_GROUP:-rg-rw-shared}"
BACKEND_APP="${BACKEND_APP:-app-rw-dev-api-e8f-wus3}"
FRONTEND_APP="${FRONTEND_APP:-app-rw-dev-web-e8f-wus3}"
API_SERVICE_PLAN="${API_SERVICE_PLAN:-plan-rw-dev-api}"
WEB_SERVICE_PLAN="${WEB_SERVICE_PLAN:-plan-rw-dev-web}"
POSTGRES_SERVER="${POSTGRES_SERVER:-psql-rw-dev-e8f-wus3}"
RUNNER_VM="${RUNNER_VM:-vm-rw-shared-runner}"

require_az() {
  command -v az >/dev/null 2>&1 || {
    echo "az CLI is required" >&2
    exit 1
  }
}
