variable "eip_name" {
  description = "The name of the Elastic IP"
  type        = string
  default     = "revlearn_nat_ip"
}

variable "subnet_id" {
  description = "The ID of the subnet for the NAT Gateway"
  type        = string
}

variable "igw_id" {
  description = "The ID of the Internet Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {
    Name     = "revlearn_nat"
    Owner    = "Trey-Crossley"
  }
}