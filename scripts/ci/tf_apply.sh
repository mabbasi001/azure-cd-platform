#!/usr/bin/env bash
# terraform apply that self-heals two transient azurerm issues that can leave a
# resource created in Azure but absent from state:
#   - diagnostic settings returning "already exists" after a successful create
#   - "inconsistent result after apply" races on fresh creates
# On any "already exists" error it imports the offending resource(s) and retries.
# Extra args (e.g. -var-file=dev.tfvars) are forwarded to apply and import.
set -uo pipefail

max=10
i=0
while :; do
  i=$((i + 1))
  out="$(terraform apply -input=false -auto-approve -no-color "$@" 2>&1)"
  rc=$?
  printf '%s\n' "$out"
  [ "$rc" -eq 0 ] && exit 0
  [ "$i" -ge "$max" ] && exit "$rc"

  # Collect every "already exists" resource id and its terraform address.
  ids="$(printf '%s' "$out" | grep -oE 'the ID "[^"]+" already exists' | sed -E 's/the ID "([^"]+)".*/\1/')"
  addrs="$(printf '%s' "$out" | grep -E '^[[:space:]]+with .*,$' | sed -E 's/^[[:space:]]+with (.+),$/\1/' | tr -d ' ')"

  if [ -z "$ids" ]; then
    exit "$rc"
  fi

  # Pair ids and addrs line-by-line (they appear in the same order).
  paste <(printf '%s\n' "$ids") <(printf '%s\n' "$addrs") | while IFS="$(printf '\t')" read -r id addr; do
    [ -n "$id" ] && [ -n "$addr" ] || continue
    echo ">> importing ${addr} <- ${id}"
    terraform import -input=false "$@" "$addr" "$id" || true
  done
done
