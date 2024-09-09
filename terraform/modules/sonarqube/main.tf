# Create a TLS private key for SonarQube SSH access
resource "tls_private_key" "sonarqube_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create an AWS key pair using the generated private key
resource "aws_key_pair" "sonarqube_key_pair" {
  key_name   = "sonarqube_key_pair"
  public_key = tls_private_key.sonarqube_private_key.public_key_openssh
}

# Save the private key locally
resource "local_file" "sonarqube_private_key_pem" { 
  filename = "sonarqube_private_key.pem"
  content  = tls_private_key.sonarqube_private_key.private_key_pem
  file_permission = "0400"
}

# IAM policy for accessing Secrets Manager (can be reused from your Jenkins config)
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerPolicy-Sonarqube"
  description = "Allows full access to AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:*"
        Resource = "*"
      }
    ]
  })
}

# IAM role to attach the Secrets Manager policy to EC2
resource "aws_iam_role" "ec2_role" {
  name               = "EC2SecretsManagerRole-Sonarqube"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the Secrets Manager policy to the EC2 role
resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Create an instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2SecretsManagerProfile-Sonarqube"
  role = aws_iam_role.ec2_role.name
}

# Define the SonarQube EC2 instance
resource "aws_instance" "sonarqube" {
  ami           = "ami-00beae93a2d981137"  
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.sonarqube_key_pair.key_name
  associate_public_ip_address = true
  ebs_optimized = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.sonarqube_sg.id
  ]

  root_block_device {
    volume_size = 20  # Adjust the volume size as needed for SonarQube
  }

  tags = {
    Name        = "sonarqube-ec2"
    Owner       = "Trey-Crossley"
    Application = "sonarqube"
  }
}

# Define the security group for SonarQube
resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube_sg"
  description = "Allow SSH and SonarQube HTTP access"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "sonarqube-sg-tc"
    Owner = "Trey-Crossley"
  }
}

# S3 bucket for SonarQube artifacts (optional)
resource "aws_s3_bucket" "sonarqube_s3_bucket" {
  bucket = "sonarqube-s3-bucket-tc"

  tags = {
    Name  = "sonarqube-s3-bucket-tc"
    Owner = "Trey-Crossley"
  }
}

# Ensure the S3 bucket is private
resource "aws_s3_bucket_acl" "sonarqube_s3_acl" {
  bucket = aws_s3_bucket.sonarqube_s3_bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.sonarqube_s3_acl_ownership]
}

# Prevent public access with object ownership
resource "aws_s3_bucket_ownership_controls" "sonarqube_s3_acl_ownership" {
  bucket = aws_s3_bucket.sonarqube_s3_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}