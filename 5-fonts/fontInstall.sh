#!/bin/bash
FontInstall=false
echo "Do you want to install Font? (y/n)"
read -n 1 FontInstall
echo
echo
if [ $FontInstall == "y" ] || [ $FontInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - Font- - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    cd ~/tmp
    git clone https://github.com/powerline/fonts.git
    cd fonts
    ./install.sh
    cd ~/tmp
    git clone https://github.com/ryanoasis/nerd-fonts.git
    cd nerd-fonts
    ./install.sh
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End Font - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
