# Outputs
output "sonarqube_instance_ip" {
  description = "The public IP for SonarQube SSH access"
  value       = aws_instance.sonarqube.public_ip
}

output "sonarqube_private_key_pem" {
  value = tls_private_key.sonarqube_private_key.private_key_pem
}