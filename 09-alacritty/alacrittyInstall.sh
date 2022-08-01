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
    mkdir -p ~/.config/alacritty
    cp -p ~/dotfiles/09-alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
    cp -p ~/dotfiles/09-alacritty/dracula.yml ~/.config/alacritty/dracula.yml
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End Alacritty - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
