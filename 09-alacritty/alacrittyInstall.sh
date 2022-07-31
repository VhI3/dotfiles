#!/bin/bash
AlacrittyInstall=false
echo "Do you want to install Alacritty? (y/n)"
read -n 1 AlacrittyInstall
echo
echo
if [ $AlacrittyInstall == "y" ] || [ $AlacrittyInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - Alacritty- - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt install pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
    cargo install alacritty
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End Alacritty - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
