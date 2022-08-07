#!/bin/bash
colorlsInstall=false
echo "Do you want to install colorls? (y/n)"
read -n 1 colorlsInstall
echo
echo
if [ $colorlsInstall == "y" ] || [ $colorlsInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - colorls - - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt install ruby-full
    sudo gem install colorls
    mkdir -p ~/.config/colorls/
    cp dark_colors.yaml ~/.config/colorls/dark_colors.yaml
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End colorls - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
