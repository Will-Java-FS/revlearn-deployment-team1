resource "tls_private_key" "beanstalk_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "beanstalk_key_pair" {
  key_name   = "beanstalk_key_pair"
  public_key = tls_private_key.beanstalk_private_key.public_key_openssh
}

resource "local_file" "beanstalk_private_key_pem" { 
  filename = "../beanstalk_private_key.pem"
  content = tls_private_key.beanstalk_private_key.private_key_pem
  file_permission = "0400"
}