output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.jenkins.public_ip
}

output "private_key_pem" {
  value = tls_private_key.jenkins_private_key.private_key_pem
}