resource "aws_s3_bucket" "app_bucket" {
  bucket = "revlearn-backend-beanstalk-bucket"

  tags = {
    Name = "revlearn-backend-beanstalk-bucket"
  }
}
