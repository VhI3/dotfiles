#!/bin/bash
FehInstall=false
echo "Do you want to install Feh? (y/n)"
read -n 1 FehInstall
echo
echo
if [ $FehInstall == "y" ] || [ $FehInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - Feh - - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt install feh
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End Feh - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
