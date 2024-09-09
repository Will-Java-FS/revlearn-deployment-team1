module "network" {
  source       = "./network"
}


module "jenkins" {
  source    = "./modules/jenkins"
  vpc_id = module.network.vpc_id
  subnet_id = module.network.public_subnet_ids[0]
}
