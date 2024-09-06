output "private_subnet_ids" {
  description = "Array of IDs of the private subnets created by the module"
  value       = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
  description = "Array of IDs of the public subnets created by the module"
  value       = aws_subnet.public_subnets[*].id
}
