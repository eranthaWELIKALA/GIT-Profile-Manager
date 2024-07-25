# Git Profile Manager

## Overview
The Git Profile Manager is a tool designed to manage multiple Git profiles on a single machine. It allows you to create new Git profiles, add existing profiles to the configuration, and manage them effortlessly.

## Features
- Manage multiple git profiles at one windows instance
- Create new Git profiles.
- Add existing Git profiles to the configuration.
- Easy-to-use command-line interface.

## Windows Installation

### Prerequisites
- [Git](https://gitforwindows.org/) must be installed.

### Using the Installer
[Download Git Profile Manager Installer](https://github.com/eranthaWELIKALA/Windows-GIT-Profile-Manager/raw/353d4d084b300ecd531b0b4dcc055eebae10b04f/output/GitProfileManagerInstaller.exe)

1. Run the `GitProfileManagerInstaller.exe`.
2. Follow the installation instructions.

## Mac Installation

### Using the Installer
[Download Git Profile Manager Installer](https://github.com/eranthaWELIKALA/GIT-Profile-Manager/raw/main/mac/git-profile-manager-dmg/installer/GitProfileManager.dmg)

1. Run the `GitProfileManager.dmg`.
2. Double click on the `install.command`.

## Linux Installation
`Implementation in progress`

## Commands
The Git Profile Manager uses a single command with different flags to perform its operations.

- **Create a new Git profile**:
  ```sh
  git-profile-manager create
  ```
- **Add a Git profile to the Configs**:
  ```sh
  git-profile-manager add
  ```

  
> [!IMPORTANT]
> **Make sure to add SSH remote URL as remotes. This solution works only with SSH URLs**
