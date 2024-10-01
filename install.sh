#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting CloudGoat installation..."

# Update package lists
sudo apt update

# Install required packages
echo "Installing required packages..."
sudo apt install -y git python3 python3-pip python3-venv curl unzip gnupg lsb-release wget

# Clone CloudGoat repository if it doesn't exist
if [ ! -d "cloudgoat" ]; then
    echo "Cloning CloudGoat repository..."
    git clone https://github.com/RhinoSecurityLabs/cloudgoat.git
fi

cd cloudgoat

# Set up Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r ./requirements.txt

# Make cloudgoat.py executable
chmod +x cloudgoat.py

# Install Terraform if not already installed
if ! command -v terraform &> /dev/null
then
    echo "Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt update && sudo apt install -y terraform
else
    echo "Terraform is already installed."
fi

# Install AWS CLI if not already installed
if ! command -v aws &> /dev/null
then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
else
    echo "AWS CLI is already installed."
fi

echo "CloudGoat installation completed successfully!"
echo "To start using CloudGoat, navigate to the 'cloudgoat' directory and activate the virtual environment:"
echo "cd cloudgoat"
echo "source .venv/bin/activate"