# Runner infrastructure

Self-hosted GitHub Actions runner for the platform. This is **shared CI/platform
infrastructure**, kept separate from the application delivery under `infra/` (in a real setup it
would be its own repository / pipeline). It is provisioned once and reused.

```
terraform/   runner VM (VM, NIC, NSG, public IP) + its module; reads the shared
             stack's remote state for the subnet and managed identity
ansible/     configures the VM: Docker (buildx + compose), registers the GitHub
             Actions runner as a systemd service, unattended security upgrades
```

## Provision

Prerequisite: the `shared` stack (in `infra/terraform/envs/shared`) is applied, since this reads
its VNet subnet and runner identity from remote state.

```
cd terraform
cp terraform.tfvars.example terraform.tfvars   # set ssh_public_key, admin_ssh_cidr
export ARM_USE_AZUREAD=true
terraform init
terraform apply
terraform output runner_public_ip
```

## Configure

```
cd ../ansible
cp inventory.ini.example inventory.ini         # set the runner public IP
ansible-playbook playbook.yml -e "github_pat=ghp_xxx"
```

The PAT is used only to fetch a short-lived runner registration token; it is not stored on the
host. See `ansible/README.md` for details.
