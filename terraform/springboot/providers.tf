terraform {

  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "revlearn-tfstate"  # Replace with the name of your S3 bucket
    region         = "us-east-1"                    # Ensure this matches your bucket's region
    dynamodb_table = "app-state"              # Replace with the name of your DynamoDB table
    encrypt        = true
    key            = "springboot/terraform.tfstate"
  }
}