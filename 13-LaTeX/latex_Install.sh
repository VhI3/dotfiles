#!/bin/bash
LaTeXInstall=false
echo "Do you want to install LaTeX? (y/n)"
read -n 1 LaTeXInstall
echo
echo
if [ $LaTeXInstall == "y" ] || [ $LaTeXInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - LaTeX - - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt purge texlive*
    sudo rm -rf /usr/local/texlive/*
    rm -rf ~/.texlive*
    sudo rm -rf /usr/local/share/texmf
    sudo rm -rf /var/lib/texmf
    sudo rm -rf /etc/texmf
    sudo apt remove tex-common --purge
    rm -rf ~/.texlive
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove

    sudo apt install wget perl-tk
    cd ~/tmp
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
    tar -xf install-tl-unx.tar.gz
    cd install-tl-20220731
    sudo ./install-tl
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End LaTeX - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
