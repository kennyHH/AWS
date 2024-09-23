#!/bin/bash

echo "This script will perform the following actions:"
echo "1. Stop and remove all Docker containers, networks, and volumes defined in docker-compose.yml"
echo "2. Remove all unused volumes"
echo "3. Remove unused data (images, containers, networks, build cache)"

read -p "Are you sure you want to proceed? (yes/no): " confirm

if [[ $confirm == "yes" ]]; then
    echo "Proceeding with Docker cleanup..."
    
    echo "Running docker compose down..."
    sudo docker compose down
    
    echo "Removing all unused volumes..."
    sudo docker volume prune --all -f
    
    echo "Removing unused data..."
    sudo docker system prune --all -f
    
    echo "Docker cleanup completed."
else
    echo "Operation cancelled."
fi
