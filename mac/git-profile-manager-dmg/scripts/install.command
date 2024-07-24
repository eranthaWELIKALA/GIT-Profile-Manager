# Set the installation directory
INSTALL_DIR="$HOME/.git-profile-manager"

rm -rf "$INSTALL_DIR"
# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy the scripts to the installation directory
cp "$(dirname "$0")/.scripts/git-profile-manager" "$INSTALL_DIR/"
cp "$(dirname "$0")/.scripts/git-profile-add.sh" "$INSTALL_DIR/"
cp "$(dirname "$0")/.scripts/git-profile-create.sh" "$INSTALL_DIR/"

# Make the scripts executable
chmod +x "$INSTALL_DIR/git-profile-manager"
chmod +x "$INSTALL_DIR/git-profile-add.sh"
chmod +x "$INSTALL_DIR/git-profile-create.sh"

# Function to add the installation directory to the PATH in a shell profile
add_to_path() {
    local profile=$1
    if [ -f "$profile" ]; then
        if ! grep -q "$INSTALL_DIR" "$profile"; then
            echo "Adding $INSTALL_DIR to PATH in $profile..."
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$profile"
            source "$profile"
        fi
    fi
}

# Add to PATH in .bashrc and .zshrc
add_to_path "$HOME/.bashrc"
add_to_path "$HOME/.zshrc"

echo "Installation complete. You can now run 'git-profile-manager.sh' from anywhere."
