output "internet_gateway_id" {
  description = "The ID of the Internet Gateway created by the module"
  value       = aws_internet_gateway.revlearn_igw.id
}
