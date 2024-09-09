#Shared

module "vpc" {
  source = "./vpc"
}

module "igw" {
  source = "./igw"
  vpc_id = module.vpc.vpc_id
}

module "subnets" {
  source = "./subnets"
  vpc_id = module.vpc.vpc_id
}

module "nat_gateway" {
  source    = "./nat"
  subnet_id = module.subnets.public_subnet_ids[0]
  igw_id    = module.igw.internet_gateway_id
}

module "routes" {
  source             = "./routes"
  vpc_id             = module.vpc.vpc_id
  nat_gateway_id     = module.nat_gateway.nat_gateway_id
  igw_id             = module.igw.internet_gateway_id
  private_subnet_ids = module.subnets.private_subnet_ids
  public_subnet_ids  = module.subnets.public_subnet_ids
}
