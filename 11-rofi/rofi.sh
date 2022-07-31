#!/bin/bash
Rofi=false
echo "Do you want to install Rofi? (y/n)"
read -n 1 Rofi
echo
echo
if [ $Rofi == "y" ] || [ $Rofi == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - Rofi- - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt install rofi
    mkdir -p ~/.config/rofi/
    ln -s -f ~/dotfiles/11-rofi/config.rasi ~/.config/rofi/config.rasi
    cd ~/tmp
    git clone https://github.com/jluttine/rofi-power-menu.git
    cd rofi-power-menu/
    cp rofi-power-menu ~/.local/bin/
    cd ~
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End Rofi - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
