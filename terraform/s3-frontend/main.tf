# S3 bucket for hosting frontend assets
resource "aws_s3_bucket" "frontend_build" {
  bucket = "revlearn-frontend-build"

  tags = {
    Name = "revlearn-frontend-build"
    Owner = "Trey-Crossley"
  }
}

# Enable versioning for the frontend bucket
resource "aws_s3_bucket_versioning" "frontend_build_versioning" {
  bucket = aws_s3_bucket.frontend_build.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Optional: S3 Bucket Policy to make files publicly accessible
resource "aws_s3_bucket_policy" "frontend_build_policy" {
  bucket = aws_s3_bucket.frontend_build.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend_build.arn}/*"
      }
    ]
  })
}

# Optional: CORS configuration if needed
resource "aws_s3_bucket_cors_configuration" "frontend_build_cors" {
  bucket = aws_s3_bucket.frontend_build.id

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}