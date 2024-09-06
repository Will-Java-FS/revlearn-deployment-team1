# Define Internet Gateway resource
resource "aws_internet_gateway" "revlearn_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name     = "revlearn_igw"
    Owner    = "Trey-Crossley"
  }
}
