# Create a TLS private key for Kafka SSH access
resource "tls_private_key" "kafka_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create an AWS key pair using the generated private key
resource "aws_key_pair" "kafka_key_pair" {
  key_name   = "kafka_key_pair"
  public_key = tls_private_key.kafka_private_key.public_key_openssh
}

# Save the private key locally
resource "local_file" "kafka_private_key_pem" { 
  filename = "kafka_private_key.pem"
  content  = tls_private_key.kafka_private_key.private_key_pem
  file_permission = "0400"
}