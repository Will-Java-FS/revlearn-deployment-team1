output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.revlearn_db_tc.id
}

output "db_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.revlearn_db_tc.endpoint
}