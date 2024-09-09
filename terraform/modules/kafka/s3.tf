# Optional: S3 bucket for Kafka data or logs
resource "aws_s3_bucket" "kafka_s3_bucket" {
  bucket = "kafka-s3-bucket-tc"

  tags = {
    Name  = "kafka-s3-bucket-tc"
    Owner = "Trey-Crossley"
  }
}

# Ensure the S3 bucket is private
resource "aws_s3_bucket_acl" "kafka_s3_acl" {
  bucket = aws_s3_bucket.kafka_s3_bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.kafka_s3_acl_ownership]
}

# Prevent public access with object ownership
resource "aws_s3_bucket_ownership_controls" "kafka_s3_acl_ownership" {
  bucket = aws_s3_bucket.kafka_s3_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}
