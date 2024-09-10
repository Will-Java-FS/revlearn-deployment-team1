#!/bin/bash

# List of directories in the order they should be destroyed
DIRECTORIES=(
  "kafka"
  "beanstalk"
  "rds"
  "s3-frontend"
  "sonarqube"
  "jenkins"
  "network"
)

# Function to run terraform destroy
destroy_terraform() {
  DIR=$1
  echo "Destroying resources in $DIR..."
  cd $DIR || { echo "Failed to enter directory $DIR"; exit 1; }
  terraform init -input=false
  terraform destroy -auto-approve
  cd - || exit
  echo "Resources destroyed in $DIR."
}

# Prompt for confirmation before proceeding
read -r -p "This script will destroy resources in the following order: ${DIRECTORIES[*]}. Are you sure you want to proceed? (y/N) " response
case "$response" in
  [yY]*)
    echo "Proceeding with Terraform destroy..."
    # Loop through all directories in the predefined order and destroy resources
    for dir in "${DIRECTORIES[@]}"; do
      destroy_terraform "$dir"
    done
    echo "Terraform destroy completed for all specified directories."
    ;;
  *)
    echo "Terraform destroy cancelled."
    ;;
esac
