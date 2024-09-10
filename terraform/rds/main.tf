data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "revlearn-tfstate"
    region = "us-east-1"
    key    = "network/terraform.tfstate"
  }
}

module "rds" {
  source = "../modules/rds"

  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids
}