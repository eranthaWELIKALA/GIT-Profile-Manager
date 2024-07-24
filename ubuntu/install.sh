#!/bin/bash

# Define the installation directory
INSTALL_DIR="$HOME/.git-profile-manager"
SCRIPT_NAME="git-profile-manager.sh"

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy the script to the installation directory
cp "$SCRIPT_NAME" "$INSTALL_DIR/"

# Make the script executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Add the installation directory to the PATH if it's not already there
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "Adding $INSTALL_DIR to PATH in .bashrc and .zshrc..."

    # Add to .bashrc
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"

    # Add to .zshrc
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.zshrc"

    # Source the appropriate file to update the current shell session
    if [ -n "$BASH_VERSION" ]; then
        source "$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        source "$HOME/.zshrc"
    fi
fi

echo "Installation complete. You can now run '$SCRIPT_NAME' from anywhere."
