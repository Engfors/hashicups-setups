locals {
  boundary_endpoint            = data.terraform_remote_state.infrastructure.outputs.boundary_endpoint
  boundary_kms_recovery_key_id = data.terraform_remote_state.infrastructure.outputs.boundary_kms_recovery_key_id
  ecs_cluster                  = data.terraform_remote_state.infrastructure.outputs.ecs_cluster
  product_database_address     = data.terraform_remote_state.infrastructure.outputs.product_database_address
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
