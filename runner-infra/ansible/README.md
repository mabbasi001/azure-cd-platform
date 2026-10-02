# Ansible — self-hosted runner

Configures the Azure VM (provisioned by `infra/terraform/envs/runner`) as a GitHub Actions
self-hosted runner: installs Docker (with buildx + compose), registers the runner against the
repository, installs it as a systemd service, and enables unattended security upgrades.

## Usage

1. Provision the VM with Terraform and note its public IP:

   ```
   cd ../terraform/envs/runner && terraform output runner_public_ip
   ```

2. Create the inventory from the example and set the host IP:

   ```
   cp inventory.ini.example inventory.ini
   # edit RUNNER_PUBLIC_IP
   ```

3. Run the playbook, passing a GitHub PAT with `repo` + `admin:org`/runner scope (used only to
   fetch a short-lived registration token — it is not stored on the host):

   ```
   ansible-playbook playbook.yml -e "github_pat=ghp_xxx"
   ```

## Roles

- `common` — base packages, Docker Engine, unattended-upgrades.
- `github_runner` — download/register/install the runner service. Idempotent: re-running
  reconfigures only if `.runner` is missing. Update `runner_version` in
  `roles/github_runner/defaults/main.yml` and re-run to upgrade.
