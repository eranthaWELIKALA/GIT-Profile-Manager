#!/bin/bash

# Function to install Git
install_git() {
    echo "Attempting to install Git..."

    if [ "$(uname)" == "Darwin" ]; then
        # MacOS
        if command -v brew &> /dev/null; then
            brew install git
        else
            echo "Homebrew is not installed. Please install Homebrew first: https://brew.sh/"
            exit 1
        fi
    elif [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y git
    elif [ -f /etc/redhat-release ]; then
        # RedHat/CentOS/Fedora
        sudo yum install -y git
    elif [ -f /etc/arch-release ]; then
        # Arch
        sudo pacman -S git
    else
        echo "Could not determine package manager. Please install Git manually."
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        echo "Failed to install Git. Please install it manually."
        exit 1
    fi

    echo "Git installed successfully."
}

# Check if the script is run directly
if [ "$(basename "$0")" == "git-profile-manager.sh" ]; then
    echo "This script cannot be run directly. Please run 'git-profile-manager.sh add' or 'git-profile-manager.sh create' instead."
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed."
    while true; do
        read -rp "Do you want to install Git? (y/n): " yn
        case $yn in
            [Yy]* ) install_git; break;;
            [Nn]* ) echo "Please install Git from https://git-scm.com/ and rerun the script."; exit 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
else
    echo "Git is installed."
fi

# Check if the current directory is a Git repository
if [ ! -d ".git" ]; then
    echo "This directory is not a Git repository. Please navigate to a Git repository directory."
    exit 1
fi

echo "Current directory is a Git repository."

profiles=()
index=1

# List all Git profiles in ~/.ssh folder
echo "Existing Git Profiles:"
echo "=================================================="

for f in "$HOME/.ssh/id_rsa_*"; do
    if [[ -f "$f" ]]; then
        profileName=$(basename "$f" | sed 's/id_rsa_//')
        echo "[$index] $profileName"
        profiles+=("$profileName")
        ((index++))
    fi
done

echo "=================================================="

# Ask user to select a Git profile
while true; do
    read -rp "Please select a Git Profile by entering the corresponding number (1 to ${#profiles[@]}): " profile_number
    if [[ "$profile_number" -ge 1 && "$profile_number" -le ${#profiles[@]} ]]; then
        selected_profile=${profiles[profile_number-1]}
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

echo "You selected: $selected_profile"

# Configure Git to use the new SSH key
git config core.sshCommand "ssh -i $HOME/.ssh/id_rsa_$selected_profile"

echo "Updated Git configurations to use the selected Git Profile."

# Final message
echo
echo "Setting up Git profile is done."
echo
exit 0
