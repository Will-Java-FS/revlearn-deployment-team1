#!/bin/bash

# Define directories
NETWORK_DIR="network"
JENKINS_DIR="jenkins"

# Function to run terraform apply
run_terraform() {
  DIR=$1
  echo "Running terraform apply in directory: $DIR"
  
  # Change to the specified directory
  cd $DIR

  # Initialize terraform
  terraform init

  # Apply terraform configuration
  terraform apply -auto-approve

  # Return to the original directory
  cd -
}

# Run terraform apply in the network directory
run_terraform $NETWORK_DIR

# Run terraform apply in the jenkins directory
run_terraform $JENKINS_DIR

echo "Terraform apply completed in both directories."

# Define the tags
OWNER_TAG="Trey-Crossley"
JENKINS_TAG="jenkins-ec2"
SONAR_TAG="sonarqube-ec2"

# Get the public DNS name of the EC2 instance with the specified tags
JENKINS_DNS=$(aws ec2 describe-instances \
    --filters "Name=tag:Owner,Values=$OWNER_TAG" "Name=tag:Name,Values=$JENKINS_TAG" \
    --query "Reservations[*].Instances[*].PublicDnsName" \
    --output text)

# Check if the PUBLIC_DNS is not empty
if [ -n "$JENKINS_DNS" ]; then
    echo "The Public DNS of Jenkins is: $JENKINS_DNS"
else
    echo "No instance found with the specified tags."
fi

SONAR_DNS=$(aws ec2 describe-instances \
    --filters "Name=tag:Owner,Values=$OWNER_TAG" "Name=tag:Name,Values=$SONAR_TAG" \
    --query "Reservations[*].Instances[*].PublicDnsName" \
    --output text)

if [ -n "$SONAR_DNS" ]; then
    echo "The Public DNS of Sonar is: $SONAR_DNS"
else
    echo "No instance found with the specified tags."
fi
