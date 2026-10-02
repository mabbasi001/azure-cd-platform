# CI/CD workflows

Both pipelines run on the self-hosted runner (`runner-infra/`) and authenticate to Azure with
GitHub OIDC — no cloud credentials are stored.

## `infra.yml`

- **PR** touching `infra/terraform/**`: `terraform fmt -check` + `validate` for every stack, then
  `plan` for `shared` and `app` (dev workspace).
- **Push to `main`**: `apply` `shared` then `app` (dev).
- **Manual** (`workflow_dispatch`): apply a chosen stack.

## `app.yml`

On push to `develop`/`main` touching `apps/**`:

1. **test** — build the stack with docker compose and exercise the API (register + tags) and the
   frontend health endpoint.
2. **build-push** — build both images for `linux/amd64` and push to ACR, tagged with the commit
   SHA and `latest`.
3. **deploy** — point the web apps at the new image, restart, and run a post-deploy smoke test.
4. **performance** — k6 load test against the API; fails the pipeline if p95 latency ≥ 800 ms or
   the error rate ≥ 1 % (catches performance regressions).

## Required repository configuration

Set as **Actions variables** (from the `identity` stack outputs):

| Variable | Value |
|----------|-------|
| `AZURE_CLIENT_ID` | OIDC app registration client id |
| `AZURE_TENANT_ID` | tenant id |
| `AZURE_SUBSCRIPTION_ID` | subscription id |

The self-hosted runner must be registered (see `runner-infra/`) and labelled
`self-hosted,linux,x64`.
