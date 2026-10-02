#!/usr/bin/env bash
# Scale the App Service plan: out (instance count) and/or up (SKU tier).
#
#   scale.sh --instances 3
#   scale.sh --sku P1v3
#   scale.sh --instances 3 --sku P1v3
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=scripts/runtime/common.sh
. ./common.sh
require_az

instances=""
sku=""
while [ $# -gt 0 ]; do
  case "$1" in
    --instances)
      instances="$2"
      shift 2
      ;;
    --sku)
      sku="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ -z "$instances" ] && [ -z "$sku" ]; then
  echo "Nothing to do: pass --instances N and/or --sku SKU" >&2
  exit 1
fi

if [ -n "$sku" ]; then
  echo "Scaling up ${APP_SERVICE_PLAN} to SKU ${sku}"
  az appservice plan update --name "$APP_SERVICE_PLAN" --resource-group "$APP_RESOURCE_GROUP" --sku "$sku"
fi

if [ -n "$instances" ]; then
  echo "Scaling out ${APP_SERVICE_PLAN} to ${instances} instance(s)"
  az appservice plan update --name "$APP_SERVICE_PLAN" --resource-group "$APP_RESOURCE_GROUP" --number-of-workers "$instances"
fi

echo "Scale complete."
