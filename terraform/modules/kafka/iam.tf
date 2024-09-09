# IAM policy for accessing Secrets Manager (if needed)
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerPolicy-Kafka"
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
  name               = "EC2SecretsManagerRole-Kafka"
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
  name = "EC2SecretsManagerProfile-Kafka"
  role = aws_iam_role.ec2_role.name
}