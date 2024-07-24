#!/bin/bash

# Check if the script is run directly
if [ "$(basename "$0")" == "git-profile-manager.sh" ]; then
    echo "This script cannot be run directly. Please run 'git-profile-manager.sh add' or 'git-profile-manager.sh create' instead."
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git from https://git-scm.com/."
    exit 1
fi

echo "Git is installed."

# Check if SSH is available
if ! command -v ssh &> /dev/null; then
    echo "SSH is not available. Please ensure that SSH is installed and available in your PATH."
    exit 1
fi

echo "SSH is available."

# Check if ssh-keygen is available
if ! command -v ssh-keygen &> /dev/null; then
    echo "ssh-keygen is not available. Please ensure that OpenSSH is installed and available in your PATH."
    exit 1
fi

echo "ssh-keygen is available."

# Check if the current directory is a Git repository
if [ ! -d ".git" ]; then
    echo "This directory is not a Git repository. Please navigate to a Git repository directory."
    exit 1
fi

echo "Current directory is a Git repository."

# Prompt for Git user name
read -rp "Please enter your Git user name: " gitUserName
echo "You entered: $gitUserName"

# Prompt for email address
read -rp "Please enter your email address: " email
echo "You entered: $email"

# Prompt for identifiable name and validate
while true; do
    read -rp "Please enter your identifiable name for Git profile (no spaces or symbols): " name
    if [[ -z "$name" ]]; then
        echo "Identifiable name cannot be empty. Please try again."
        continue
    fi
    if [[ "$name" =~ [^a-zA-Z0-9] ]]; then
        echo "Identifiable name cannot contain spaces or symbols. Please try again."
        continue
    fi
    break
done
echo "You entered: $name"

# Check if the SSH key file already exists
sshKeyFile="$HOME/.ssh/id_rsa_$name"
echo "$sshKeyFile"
if [ -f "$sshKeyFile" ]; then
    echo "There is already a Git profile with the given identifiable name."
    read -rp "Do you want to remove the existing key files? [y or n]: " removeExisting
    if [[ "$removeExisting" =~ ^[Yy]$ ]]; then
        echo "Removing existing key files..."
        rm "$sshKeyFile" "$sshKeyFile.pub"
        if [ $? -ne 0 ]; then
            echo "Failed to remove existing key files."
            exit 1
        fi
        echo "Existing key files removed successfully."
    else
        echo "Exiting without making changes."
        exit 1
    fi
else
    echo "No existing SSH key file found or existing files removed."
fi

# Generate the SSH key
ssh-keygen -t rsa -C "$email" -f "$sshKeyFile"
if [ $? -ne 0 ]; then
    echo "Failed to generate SSH key."
    exit 1
fi
echo "SSH key successfully generated at $sshKeyFile."

# List all Git profiles in ~/.ssh folder
echo "Listing all Git profiles in ~/.ssh folder:"
echo "=================================================="
index=1
for f in "$HOME/.ssh/id_rsa_*"; do
    if [[ -f "$f" ]]; then
        profileName=$(basename "$f" | sed 's/id_rsa_//')
        echo "[$index] $profileName"
        ((index++))
    fi
done
echo "=================================================="

# Display the public key
sshPublicKeyFile="$sshKeyFile.pub"
echo
echo
echo
echo "=================================================="
echo "=================================================="
echo "SSH public key:"
echo "=================================================="
echo "=================================================="
cat "$sshPublicKeyFile"
echo "=================================================="
echo "=================================================="
echo
echo
echo

# Configure Git to use the new SSH key
git config core.sshCommand "ssh -i \"$sshKeyFile\""
echo "Git SSH configuration updated to use the new key."

# Configure Git user name and email
git config user.name "$gitUserName"
git config user.email "$email"
echo
echo "Git user name and email configured:"
echo "user.name: $gitUserName"
echo "user.email: $email"

# Final message
echo
echo "Setting up Git profile is done."
echo
exit 0
