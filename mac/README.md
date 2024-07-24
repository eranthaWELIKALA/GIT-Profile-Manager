To ensure that the installation script updates both `~/.zshrc` and `~/.bashrc` on macOS, you can modify the `install.command` script accordingly. Here's how to update the script to handle both shells:

### Step 1: Prepare the Installation Script

Create an `install.command` script with the following content:

```sh
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
```

### Step 2: Make the Script Executable

Make sure the `install.command` script is executable:

```sh
chmod +x install.command
```

### Step 3: Create the DMG File

Ensure your directory structure is as follows:

```
git-profile-manager-dmg/
├── scripts/
│   ├── git-profile-manager.sh
│   ├── install.sh
│   └── install.command
```

Create the DMG file using `create-dmg`:

```sh
brew install create-dmg

create-dmg \
  --volname "Git Profile Manager" \
  --window-size 500 300 \
  --icon-size 100 \
  --app-drop-link 300 200 \
  git-profile-manager-dmg/installer/GitProfileManager.dmg \
  git-profile-manager-dmg/scripts
```

### Summary

1. **Prepare the Directory Structure**: Organize your scripts and the installation script.
2. **Create the Installation Script**: Ensure the installation script updates both `~/.bashrc` and `~/.zshrc`.
3. **Make the Script Executable**: Ensure the script can be executed by the user.
4. **Create the DMG File**: Use `create-dmg` to create a user-friendly DMG installer.

This approach will ensure that the installation directory is added to the `PATH` in both `~/.bashrc` and `~/.zshrc`, making the `git-profile-manager.sh` script executable from any terminal session on macOS.