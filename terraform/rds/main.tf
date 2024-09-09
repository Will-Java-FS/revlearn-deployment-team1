data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "revlearn-tfstate"
    region = "us-east-1"
    key    = "terraform.tfstate"
  }
}

module "rds" {
  source = "../modules/rds"

  vpc_id     = data.terraform_remote_state.network.outputs.network_outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.network_outputs.public_subnet_ids
}