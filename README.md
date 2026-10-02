# RealWorld Continuous Delivery Platform

A scalable, secure, fully automated continuous-delivery setup for a
[RealWorld](https://github.com/gothinkster/realworld) application on Azure.

Infrastructure is provisioned as code with Terraform, the self-hosted CI runner is configured
with Ansible, and build/test/deploy run through GitHub Actions authenticating to Azure via OIDC
(no stored cloud credentials).

## Architecture

| Tier | Technology |
|------|------------|
| Frontend | React/Redux, served by nginx (container) |
| Backend | FastAPI (Python), Uvicorn (container) |
| Database | Azure Database for PostgreSQL |
| Registry | Azure Container Registry |
| Compute | Azure Web App for Containers |
| CI runner | Self-hosted GitHub Actions runner on an Azure VM |
| Secrets | Azure Key Vault + Managed Identity |
| Observability | Log Analytics, Application Insights, Azure Monitor |

Deployment flows:

```
App:    GitHub -> Actions -> OIDC -> Azure -> build -> ACR -> Web App
Infra:  GitHub -> Terraform -> Azure
Runner: Terraform -> Azure VM -> Ansible -> GitHub runner
```

See `docs/architecture/` for the full diagram and write-up.

## Layout

```
apps/        RealWorld frontend + backend, each with a Dockerfile
infra/
  terraform/ reusable modules + per-environment stacks (shared, dev)
  ansible/   self-hosted runner provisioning
scripts/
  backup/    daily database backup + restore verification
  runtime/   start / stop / scale helpers
docs/        architecture diagram, naming convention, documentation
```

## The application

`apps/frontend` and `apps/backend` are existing RealWorld implementations, vendored and
containerized for this platform. The app is the deployment target; the focus of this repository
is the delivery pipeline and infrastructure around it. See `apps/PROVENANCE.md` for upstream
sources.

## Getting started

Run the apps locally:

```
cd apps && docker compose up --build
```

Infrastructure and pipelines are documented under `infra/` and `.github/workflows/`.

## Branching

- `main` — protected, production, always deployable.
- `develop` — integration branch; feature work merges here first.
- `feature/*`, `fix/*` — branched off `develop`.
- `release/*` — cut from `develop`, merged to `main` and tagged.
