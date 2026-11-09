# subscription_id comes from ARM_SUBSCRIPTION_ID (never committed).
location    = "westus3"
environment = "dev"

# Postgres HA requires a GP SKU first, then HA enabled in a second apply
# (Azure rejects enabling HA while the server is still Burstable). This file
# tracks the current step; flip to true once the SKU is GP.
postgres_ha_enabled = true

# Dev runs a single instance per plan to keep cost down; prod keeps min 2.
autoscale_min = 1
