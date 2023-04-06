locals {
  product_database_address     = data.terraform_remote_state.infrastructure.outputs.product_database_address
  product_database_password    = data.terraform_remote_state.infrastructure.outputs.product_database_password
  product_database_username    = data.terraform_remote_state.infrastructure.outputs.product_database_username
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
