#!/bin/bash

# Check if sudo is installed
if ! command -v sudo &> /dev/null
then
    echo "sudo is not installed. Please run 'apt install -y sudo' first."
    exit 1
fi

# Set variables
REMOTE_REPO="https://github.com/Jared-02/debian-scripts.git"
TMP_DIR=$(mktemp -d "/tmp/repo-XXXXXXXX")
CONF_DIR="nginx-conf"
DEST_DIR="/etc/nginx"

# Install git
if ! command -v git &> /dev/null
then
    sudo apt-get update
    sudo apt-get install -y git
fi

git clone --no-checkout "$REMOTE_REPO" "$TMP_DIR"
cd "$TMP_DIR"

git sparse-checkout init --cone
git sparse-checkout set "$CONF_DIR"
git checkout

# Copy nginx configuration files to destination directory
sudo cp -r "$CONF_DIR"/* "$DEST_DIR"/
sudo mkdir /etc/nginx/sites-available /etc/nginx/sites-enabled

# Clean up temporary directory
cd ..
sudo rm -rf "$TMP_DIR"

echo "Successfully!"