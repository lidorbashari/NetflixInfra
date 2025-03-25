#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# System Update and Basic Tools Installation
sudo apt-get update
sudo apt-get install -y ca-certificates curl git apt-transport-https

# Docker Repository Setup and Installation
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
newgrp docker # Activate the group change without logout

# Check if EBS volume is already formatted and mounted
if ! findmnt /mnt/ebs; then
  echo "EBS volume not mounted. Formatting and mounting..."
  sudo mkfs.ext4 /dev/nvme1n1
  sudo mkdir -p /mnt/ebs
  sudo mount /dev/nvme1n1 /mnt/ebs
  echo "/dev/nvme1n1 /mnt/ebs ext4 defaults 0 0" | sudo tee -a /etc/fstab
fi

# Create persistent data directory
sudo mkdir -p /mnt/ebs/persistent_data/catalog_data
sudo mkdir -p /mnt/ebs/persistent_data/prometheus_data
sudo mkdir -p /mnt/ebs/persistent_data/grafana_data
sudo mkdir -p /mnt/ebs/persistent_data/prometheus_config

# Set correct ownership for persistent directories
sudo chown -R ubuntu:ubuntu /mnt/ebs/persistent_data/catalog_data
sudo chown -R ubuntu:ubuntu /mnt/ebs/persistent_data/prometheus_data
sudo chown -R 472:472 /mnt/ebs/persistent_data/grafana_data

# Set permissions for Grafana directory
sudo chmod -R 755 /mnt/ebs/persistent_data/grafana_data

# Delete all files in prometheus data (let prometheus create new ones)
sudo rm -rf /mnt/ebs/persistent_data/prometheus_data/*

# Define a temporary directory
TEMP_DIR=/home/ubuntu/temp

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Clone the repository to the temporary directory
git clone https://github.com/lidorbashari/NetflixInfra.git "$TEMP_DIR/NetflixInfra"
sudo cp "$TEMP_DIR/NetflixInfra/prometheus.yaml" /mnt/ebs/persistent_data/prometheus_config/prometheus.yaml
cd  "$TEMP_DIR/NetflixInfra"

# Set the correct permissions for Prometheus data directory
sudo chown -R ubuntu:ubuntu /mnt/ebs/persistent_data/prometheus_data
sudo chmod -R 755 /mnt/ebs/persistent_data/prometheus_data

# Docker Compose Deployment (Run as regular user)
docker compose up -d
newgrp docker