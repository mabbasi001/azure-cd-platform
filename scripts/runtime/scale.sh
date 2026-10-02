#!/usr/bin/env bash
# Scale an App Service plan: out (instance count) and/or up (SKU tier). The api and
# web tiers are separate plans, so pass --tier to pick one (default: both).
#
#   scale.sh --instances 3
#   scale.sh --tier api --instances 3
#   scale.sh --tier web --sku P1v3
#   scale.sh --instances 3 --sku P1v3
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=scripts/runtime/common.sh
. ./common.sh
require_az

instances=""
sku=""
tier="both"
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
    --tier)
      tier="$2"
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

case "$tier" in
  api) plans="$API_SERVICE_PLAN" ;;
  web) plans="$WEB_SERVICE_PLAN" ;;
  both) plans="$API_SERVICE_PLAN $WEB_SERVICE_PLAN" ;;
  *)
    echo "Unknown --tier: $tier (expected api, web, or both)" >&2
    exit 1
    ;;
esac

for plan in $plans; do
  if [ -n "$sku" ]; then
    echo "Scaling up ${plan} to SKU ${sku}"
    az appservice plan update --name "$plan" --resource-group "$APP_RESOURCE_GROUP" --sku "$sku"
  fi
  if [ -n "$instances" ]; then
    echo "Scaling out ${plan} to ${instances} instance(s)"
    az appservice plan update --name "$plan" --resource-group "$APP_RESOURCE_GROUP" --number-of-workers "$instances"
  fi
done

echo "Scale complete."
