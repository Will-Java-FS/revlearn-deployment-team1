resource "tls_private_key" "jenkins_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = "jenkins_key_pair"
  public_key = tls_private_key.jenkins_private_key.public_key_openssh
}

resource "local_file" "jenkins_private_key_pem" { 
  filename = "jenkins_private_key.pem"
  content = tls_private_key.jenkins_private_key.private_key_pem
  file_permission = "0400"
}


resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerPolicy"
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

resource "aws_iam_role" "ec2_role" {
  name               = "EC2SecretsManagerRole"
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

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role     = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2SecretsManagerProfile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "jenkins" {
  ami           = "ami-00beae93a2d981137"
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id
  key_name = aws_key_pair.jenkins_key_pair.key_name
  associate_public_ip_address = true
  ebs_optimized = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
    ]

  root_block_device {
    volume_size = 8 
  }


  tags = {
    Name = "jenkins-ec2"
    Owner    = "Trey-Crossley"
    Application = "jenkins"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
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
    Name = "jenkins-sg-tc"
    Owner    = "Trey-Crossley"
  }
}

#Create S3 bucket for Jenksin Artifacts
resource "aws_s3_bucket" "jenkins-s3-bucket" {
  bucket = "jenkins-s3-bucket-tc"

   tags = {
    Name = "jenkins-s3-bucket-tc"
    Owner    = "Trey-Crossley"
  }
}

#make sure is private and not open to public and create Access control List
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.jenkins-s3-bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.jenkins-s3-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}


