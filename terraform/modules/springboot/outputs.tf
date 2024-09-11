output "instance_ip" {
  description = "The public IP for SSH access"
  value       = aws_instance.springboot.public_ip
}

output "private_key_pem" {
  value = tls_private_key.springboot_private_key.private_key_pem
}