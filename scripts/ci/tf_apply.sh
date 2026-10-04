#!/usr/bin/env bash
# terraform apply that self-heals the known azurerm quirk where creating an
# azurerm_monitor_diagnostic_setting returns "already exists" even though the
# create actually succeeded. On that error, import the resource and retry.
# Any extra args (e.g. -var-file=dev.tfvars) are forwarded to apply and import.
set -uo pipefail

max=6
i=0
while :; do
  i=$((i + 1))
  out="$(terraform apply -input=false -auto-approve -no-color "$@" 2>&1)"
  rc=$?
  printf '%s\n' "$out"
  [ "$rc" -eq 0 ] && exit 0
  [ "$i" -ge "$max" ] && exit "$rc"

  id="$(printf '%s' "$out" | grep -oE 'the ID "[^"]+" already exists' | head -1 | sed -E 's/the ID "([^"]+)".*/\1/')"
  addr="$(printf '%s' "$out" | grep -E 'with .*azurerm_monitor_diagnostic_setting' | head -1 | sed -E 's/.*with ([^,]+),.*/\1/' | tr -d ' ')"

  if [ -n "$id" ] && [ -n "$addr" ]; then
    echo ">> importing ${addr} <- ${id}"
    terraform import -input=false "$@" "$addr" "$id" || exit "$rc"
  else
    exit "$rc"
  fi
done
