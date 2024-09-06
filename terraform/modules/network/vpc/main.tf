resource "aws_vpc" "revlearn_vpc" {
  cidr_block = var.cidr_block

  tags = var.tags

  enable_dns_hostnames = true
  enable_dns_support = true
}