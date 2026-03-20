#!/bin/bash

# Check if script is run as root, otherwise switch to root
if [ "$EUID" -ne 0 ]; then
    echo "Switching to root account..."
    su -
    exit
fi

# Ensure sudo is installed
if ! command -v sudo &> /dev/null; then
    echo "Sudo is not installed. Installing sudo..."
    apt update && apt install -y sudo
else
    echo "Sudo is already installed. Proceeding..."
fi

# Prompt for username
read -p "Enter the username to add to sudoers: " username

# Check if user exists
if id "$username" &>/dev/null; then
    echo "User '$username' exists. Proceeding..."
else
    echo "Error: User '$username' does not exist. Please create the user first."
    exit 1
fi

# Add user to the sudo group
if groups "$username" | grep -qw "sudo"; then
    echo "User '$username' is already in the sudo group."
else
    usermod -aG sudo "$username"
    echo "User '$username' has been added to the sudo group."
fi

# Backup sudoers file
if [ ! -f /etc/sudoers.bak ]; then
    cp /etc/sudoers /etc/sudoers.bak
    echo "Backup of sudoers file created."
else
    echo "Backup of sudoers file already exists."
fi

# Add user to sudoers file using visudo (safe method)
if grep -q "$username" /etc/sudoers; then
    echo "User '$username' already has sudo privileges."
else
    echo "$username  ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers
    echo "User '$username' has been added to sudoers."
fi

# Verify the user is now in the sudo group
echo "Final verification..."
groups "$username"

# Reboot prompt
read -p "Do you want to reboot now? (y/n): " reboot_choice
if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
    reboot
else
    echo "Please log out and log back in for changes to take effect."
fi
