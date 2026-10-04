data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-rw-shared-tfstate"
    storage_account_name = "strwsharedtfstatee8fwus3"
    container_name       = "tfstate"
    key                  = "shared.tfstate"
    use_azuread_auth     = true
  }
}

locals {
  shared = data.terraform_remote_state.shared.outputs

  tags = {
    product   = "rw"
    env       = "shared"
    managedBy = "terraform"
    purpose   = "ci-runner"
  }
}

module "runner" {
  source              = "./modules/runner"
  name                = "rw-shared-runner"
  location            = var.location
  resource_group_name = local.shared.resource_group_name
  subnet_id           = local.shared.subnet_ids["snet-rw-shared-runner"]
  identity_id         = local.shared.runner_identity_id
  vm_size             = var.vm_size
  ssh_public_key      = var.ssh_public_key
  admin_ssh_cidr      = var.admin_ssh_cidr
  tags                = local.tags
}
