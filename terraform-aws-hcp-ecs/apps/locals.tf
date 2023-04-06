locals {
  product_database_address          = data.terraform_remote_state.infrastructure.outputs.product_database_address
  product_database_credentials_path = data.terraform_remote_state.vault.outputs.product_database_credentials_path
  ecs_security_group                = data.terraform_remote_state.infrastructure.outputs.product_database_address
  consul_attributes                 = data.terraform_remote_state.infrastructure.outputs.consul_attributes
  vpc_id                            = data.terraform_remote_state.infrastructure.outputs.vpc_id
  private_subnets                   = data.terraform_remote_state.infrastructure.outputs.private_subnets
  public_subnets                    = data.terraform_remote_state.infrastructure.outputs.public_subnets
}

data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = "engfors-hashicorp"
    workspaces = {
      name = "hashicups-setups-infrastructure"
    }
  }
}

data "terraform_remote_state" "vault" {
  backend = "remote"

  config = {
    organization = "engfors-hashicorp"
    workspaces = {
      name = "hashicups-setups-vault"
    }
  }
}
