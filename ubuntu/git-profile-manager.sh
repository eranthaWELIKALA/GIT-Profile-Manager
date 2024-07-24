#!/bin/bash

# Check for arguments
if [ -z "$1" ]; then
    echo "No command provided. Use create or add."
    echo "Help: git-profile-manager add or git-profile-manager create"
    echo
    exit 1
fi

create_profile() {
    echo "Creating a new Git profile..."
    # Include your git-profile-create script logic here
    ./git-profile-create.sh
    return 0
}

add_profile() {
    echo "Adding an existing Git profile..."
    # Include your git-profile-add script logic here
    ./git-profile-add.sh
    return 0
}

case "$1" in
    create)
        create_profile
        ;;
    add)
        add_profile
        ;;
    *)
        echo "Invalid command provided. Use create or add."
        echo "Help: git-profile-manager add or git-profile-manager create"
        echo
        exit 1
        ;;
esac
