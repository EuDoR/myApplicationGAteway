!#/bin/bash

# Update package information
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to the docker group
sudo usermod -aG docker $USER
