#!/bin/bash
RofiFehInstall=false
echo "Do you want to install RofiFeh? (y/n)"
read -n 1 RofiFehInstall
echo
echo
if [ $RofiFehInstall == "y" ] || [ $RofiFehInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - RofiFeh- - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt install rofi
    sudo apt install feh
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End RofiFeh - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
