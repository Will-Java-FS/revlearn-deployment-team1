data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "revlearn-tfstate"
    region = "us-east-1"
    key    = "terraform.tfstate"
  }
}

module "kafka" {
  source = "../modules/kafka"

  vpc_id     = data.terraform_remote_state.network.outputs.network_outputs.vpc_id
  subnet_id = data.terraform_remote_state.network.outputs.network_outputs.public_subnet_ids[0]
}