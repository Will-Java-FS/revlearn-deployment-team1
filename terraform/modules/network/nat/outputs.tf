output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gateway.id
}

output "eip_id" {
  description = "The ID of the Elastic IP"
  value       = aws_eip.nat_ip.id
}
