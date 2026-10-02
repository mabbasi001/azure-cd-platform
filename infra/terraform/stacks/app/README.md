# App tier (environment-agnostic)

One stack for the application tier (Postgres, App Insights, web apps, Key Vault secrets, RBAC).
Environments are **Terraform workspaces**, not copied folders — each workspace keeps its own
state and reads its values from a matching `*.tfvars` file.

```
terraform init

# dev
terraform workspace select dev || terraform workspace new dev
terraform apply -var-file=dev.tfvars

# prod (later) — no new folder, just a workspace + tfvars
cp prod.tfvars.example prod.tfvars
terraform workspace new prod
terraform apply -var-file=prod.tfvars
```

The `environment` variable (set per tfvars) feeds the resource names, so `dev` produces
`rg-rw-dev`, `app-rw-dev-api-...`, and `prod` produces `rg-rw-prod`, `app-rw-prod-api-...`.
State is isolated automatically per workspace in the backend.
