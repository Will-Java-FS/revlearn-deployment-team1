data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "revlearn-tfstate"
    region = "us-east-1"
    key    = "network/terraform.tfstate"
  }
}

module "beanstalk" {
  source = "../modules/beanstalk"

  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
}