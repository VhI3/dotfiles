#!/bin/bash
dunstInstall=false
echo "Do you want to install dunst? (y/n)"
read -n 1 dunstInstall
echo
echo
if [ $dunstInstall == "y" ] || [ $dunstInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - dunst - - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt install dunst libnotify-bin
    mkdir -p ~/.config/dunst/
    cp dunstrc ~/.config/dunst/dunstrc
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End dunst - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
