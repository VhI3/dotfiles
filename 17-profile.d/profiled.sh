#!/bin/bash
profiledInstall=false
echo "Do you want to install specific settings in profile.d? (y/n)"
read -n 1 profiledInstall
echo
echo
if [ $profiledInstall == "y" ] || [ $profiledInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - profile.d - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo ln -s -f ~/dotfiles/profile.d/VHI3-settings.sh /etc/profile.d/
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End profile.d - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi