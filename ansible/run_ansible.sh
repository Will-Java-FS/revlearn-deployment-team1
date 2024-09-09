#!/bin/bash

# Default role name
DEFAULT_ROLE_NAME="jenkins"

# Role name from argument or default to jenkins
ROLE_NAME="${1:-$DEFAULT_ROLE_NAME}"

# Define base paths for playbooks and private keys
BASE_PLAYBOOK_PATH="./"
BASE_PRIVATE_KEY_PATH="../terraform/"

# Dynamically construct playbook and private key paths
PLAYBOOK="${BASE_PLAYBOOK_PATH}${ROLE_NAME}/playbook.yml"
PRIVATE_KEY="${BASE_PRIVATE_KEY_PATH}${ROLE_NAME}_private_key.pem"

# Path to the inventory file
INVENTORY_FILE="inventory.aws_ec2.yaml"

# Remote user to connect to the EC2 instance
REMOTE_USER="ec2-user"

# Check if the private key file exists
if [ ! -f "$PRIVATE_KEY" ]; then
    echo "Error: Private key file not found: $PRIVATE_KEY"
    exit 1
fi

# Check if the inventory file exists
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Error: Inventory file not found: $INVENTORY_FILE"
    exit 1
fi

# Check if the playbook file exists
if [ ! -f "$PLAYBOOK" ]; then
    echo "Error: Playbook file not found: $PLAYBOOK"
    exit 1
fi

# Execute the Ansible playbook with the specified parameters
ansible-playbook -i "$INVENTORY_FILE" -u "$REMOTE_USER" --private-key="$PRIVATE_KEY" "$PLAYBOOK" --ssh-extra-args='-o IdentitiesOnly=yes' -vv
