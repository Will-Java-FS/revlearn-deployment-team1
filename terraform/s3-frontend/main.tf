# S3 bucket for hosting frontend assets
resource "aws_s3_bucket" "frontend_build" {
  bucket = "revlearn-frontend-build"

  tags = {
    Name = "revlearn-frontend-build"
    Owner = "Trey-Crossley"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.frontend_build.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access" {
  bucket = aws_s3_bucket.frontend_build.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_public_access,
  ]

  bucket = aws_s3_bucket.frontend_build.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "frontend_build_website" {
  bucket = aws_s3_bucket.frontend_build.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"  # Serve index.html for all paths (common for single-page apps)
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
# resource "aws_s3_bucket_policy" "frontend_build_policy" {
#   bucket = aws_s3_bucket.frontend_build.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = "*",
#         Action = [ 
#           "s3:GetObject",
#         ],
#         Resource = "${aws_s3_bucket.frontend_build.arn}/*"
#       }
#     ]
#   })
# }

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
