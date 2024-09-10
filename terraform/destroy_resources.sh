#!/bin/bash

# Function to run terraform destroy
destroy_terraform() {
  DIR=$1
  echo "Destroying resources in $DIR..."
  cd $DIR || { echo "Failed to enter directory $DIR"; exit 1; }
  terraform destroy -auto-approve
  cd - || exit
  echo "Resources destroyed in $DIR."
}

# Check if at least one argument (directory) is provided
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <directory1> <directory2> ... <directoryN>"
  exit 1
fi

# Prompt for confirmation once at the beginning
read -r -p "This script will destroy resources in all specified directories. Are you sure you want to proceed? (y/N) " response
case "$response" in
  [yY]*)
    echo "Proceeding with Terraform destroy..."
    # Loop through all provided directories and destroy resources
    for dir in "$@"; do
      destroy_terraform "$dir"
    done
    echo "Terraform destroy completed for all specified directories."
    ;;
  *)
    echo "Terraform destroy cancelled."
    ;;
esac
