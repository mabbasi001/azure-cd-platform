subscription_id = "00000000-0000-0000-0000-000000000000"
location        = "westus3"
environment     = "dev"

# Postgres HA requires a GP SKU first, then HA enabled in a second apply
# (Azure rejects enabling HA while the server is still Burstable). This file
# tracks the current step; flip to true once the SKU is GP.
postgres_ha_enabled = true
