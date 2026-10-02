# Runtime scripts

Operational helpers for starting, stopping and scaling the running environment. All are
`az`-based and idempotent; resource names default to the `dev` environment and can be overridden
via environment variables (see `common.sh`).

| Script | Purpose |
|--------|---------|
| `start.sh` | Start PostgreSQL and both web apps. `INCLUDE_RUNNER=true` also starts the runner VM. |
| `stop.sh` | Stop the web apps and PostgreSQL (and deallocate the runner VM with `INCLUDE_RUNNER=true`) to save cost. |
| `scale.sh` | Scale the App Service plan: `--instances N` (scale out) and/or `--sku P1v3` (scale up). |

Examples:

```
./start.sh
INCLUDE_RUNNER=true ./stop.sh
./scale.sh --instances 3 --sku P1v3
```
