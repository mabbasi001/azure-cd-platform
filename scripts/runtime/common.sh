#!/usr/bin/env bash
# Shared defaults for the runtime scripts. Override any value via the environment.
set -euo pipefail

APP_RESOURCE_GROUP="${APP_RESOURCE_GROUP:-rg-rw-dev}"
SHARED_RESOURCE_GROUP="${SHARED_RESOURCE_GROUP:-rg-rw-shared}"
BACKEND_APP="${BACKEND_APP:-app-rw-dev-api-e8f-neu}"
FRONTEND_APP="${FRONTEND_APP:-app-rw-dev-web-e8f-neu}"
APP_SERVICE_PLAN="${APP_SERVICE_PLAN:-plan-rw-dev}"
POSTGRES_SERVER="${POSTGRES_SERVER:-psql-rw-dev-e8f-neu}"
RUNNER_VM="${RUNNER_VM:-vm-rw-shared-runner}"

require_az() {
  command -v az >/dev/null 2>&1 || {
    echo "az CLI is required" >&2
    exit 1
  }
}
