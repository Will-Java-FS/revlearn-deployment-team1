variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  type        = string
}

variable "igw_id" {
  description = "The ID of the Internet Gateway"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of IDs of private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of IDs of public subnets"
  type        = list(string)
}
