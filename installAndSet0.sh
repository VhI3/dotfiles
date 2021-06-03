#!/bin/bash

clear
echo "  - - - - - - VHI3- - - - - - - -"
echo "/ D O T F I L E S   M A N A G E R \\"
echo "- - - - - - - - - - - - - - - - -"

sudo apt install command-not-found apt-file
sudo apt update
sudo apt-file update
sudo apt upgrade
echo "- - - - - - - - - - - - - - - - -"
echo "    I N S T A L L   B A S I C S  "
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Intel Microcode- - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install intel-microcode
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Git - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install git
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Ctags - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install exuberant-ctags
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - WGET- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install wget
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - CURL- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install curl
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - XORG- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install xorg
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Suckless- - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install suckless-tools
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - lightdm- - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install lightdm
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - I3      - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install i3
sudo apt update
sudo apt upgrade
sudo apt autoremove
reboot
cd ~
