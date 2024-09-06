output "private_route_table_ids" {
  description = "List of IDs of private route tables created by the module"
  value       = aws_route_table.private[*].id
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables created by the module"
  value       = aws_route_table.public[*].id
}
