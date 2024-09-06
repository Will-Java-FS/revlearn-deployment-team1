# Create private subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.private_subnet_availability_zones[count.index]

  tags = {
    Name                                     = "revlearn_private_subnet${count.index + 1}"
    Owner                                    = "Trey-Crossley"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.public_subnet_availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                     = "revlearn_public_subnet${count.index + 1}"
    Owner                                    = "Trey-Crossley"
  }
}
