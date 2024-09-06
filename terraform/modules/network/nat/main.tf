resource "aws_eip" "nat_ip" {
  domain = "vpc"
  tags   = var.tags
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = var.subnet_id
  tags          = var.tags
}

