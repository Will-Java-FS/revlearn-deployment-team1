resource "tls_private_key" "springboot_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "springboot_key_pair" {
  key_name   = "springboot_key_pair"
  public_key = tls_private_key.springboot_private_key.public_key_openssh
}

resource "local_file" "springboot_private_key_pem" {
  filename      = "../springboot_private_key.pem"
  content       = tls_private_key.springboot_private_key.private_key_pem
  file_permission = "0400"
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerPolicy-SpringBoot"
  description = "Allows full access to AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:*"
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "ec2:DescribeInstances",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name               = "EC2SecretsManagerRole-SpringBoot"
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

resource "aws_iam_policy" "ecr_access_policy" {
  name        = "ECRAccessPolicy"
  description = "Policy to allow ECR access for EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access_policy_attachment" {
  policy_arn = aws_iam_policy.ecr_access_policy.arn
  role      = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role     = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2SecretsManagerProfile-SpringBoot"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "springboot" {
  ami                    = "ami-00beae93a2d981137"  # Use an appropriate AMI for your region and OS
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.springboot_key_pair.key_name
  associate_public_ip_address = true
  ebs_optimized          = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.springboot_sg.id
  ]

  root_block_device {
    volume_size = 8
  }

  tags = {
    Name        = "springboot-ec2"
    Owner       = "Trey-Crossley"
    Application = "springboot"
  }
}

resource "aws_security_group" "springboot_sg" {
  name        = "springboot_sg"
  description = "Allow SSH and HTTP"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name  = "springboot-sg-tc"
    Owner = "Trey-Crossley"
  }
}

resource "aws_s3_bucket" "springboot_s3_bucket" {
  bucket = "springboot-s3-bucket-tc"  # Static bucket name

  tags = {
    Name  = "springboot-s3-bucket-tc"
    Owner = "Trey-Crossley"
  }
}



