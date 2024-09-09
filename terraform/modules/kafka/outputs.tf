# Outputs
output "kafka_instance_ip" {
  description = "The public IP for Kafka SSH access"
  value       = aws_instance.kafka.public_ip
}

output "kafka_private_key_pem" {
  value = tls_private_key.kafka_private_key.private_key_pem
}