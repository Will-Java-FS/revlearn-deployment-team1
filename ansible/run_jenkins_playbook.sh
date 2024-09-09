#!/bin/bash

# Path to the inventory file
INVENTORY_FILE="inventory.aws_ec2.yaml"

# Remote user to connect to the EC2 instance
REMOTE_USER="ec2-user"

# Path to the SSH private key file
PRIVATE_KEY="../terraform/jenkins_private_key.pem"

# Array of playbook files
PLAYBOOKS=(
    "./jenkins/playbook.yml"
    # Add more playbook paths here if needed
)

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

# Iterate over the array of playbook files
for PLAYBOOK in "${PLAYBOOKS[@]}"; do
    # Check if the playbook file exists
    if [ ! -f "$PLAYBOOK" ]; then
        echo "Error: Playbook file not found: $PLAYBOOK"
        exit 1
    fi

    # Execute the Ansible playbook with the specified parameters
    ansible-playbook -i "$INVENTORY_FILE" -u "$REMOTE_USER" --private-key="$PRIVATE_KEY" "$PLAYBOOK" --ssh-extra-args='-o IdentitiesOnly=yes' -vv
done
