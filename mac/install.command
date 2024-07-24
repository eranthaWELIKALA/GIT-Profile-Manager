#!/bin/bash

# Set the installation directory
INSTALL_DIR="$HOME/.git-profile-manager"

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy the scripts to the installation directory
cp "$(dirname "$0")/git-profile-manager.sh" "$INSTALL_DIR/"
cp "$(dirname "$0")/install.sh" "$INSTALL_DIR/"

# Make the scripts executable
chmod +x "$INSTALL_DIR/git-profile-manager.sh"
chmod +x "$INSTALL_DIR/install.sh"

# Add the installation directory to the PATH if it's not already there
SHELL_PROFILE=""

if [ -n "$BASH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
else
    echo "Unsupported shell. Please add $INSTALL_DIR to your PATH manually."
    exit 1
fi

if ! grep -q "$INSTALL_DIR" "$SHELL_PROFILE"; then
    echo "Adding $INSTALL_DIR to PATH in $SHELL_PROFILE..."
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_PROFILE"
    source "$SHELL_PROFILE"
fi

echo "Installation complete. You can now run 'git-profile-manager.sh' from anywhere."
