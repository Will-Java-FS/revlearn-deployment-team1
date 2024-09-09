# Define the Kafka EC2 instance
resource "aws_instance" "kafka" {
  ami           = "ami-00beae93a2d981137" 
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.kafka_key_pair.key_name
  associate_public_ip_address = true
  ebs_optimized = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.kafka_sg.id
  ]

  root_block_device {
    volume_size = 30  # Adjust the volume size as needed for Kafka
  }

  tags = {
    Name        = "kafka-ec2"
    Owner       = "Trey-Crossley"
    Application = "kafka"
  }
}