#!/bin/bash
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Ranger- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Install Ranger - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt update
sudo apt install ranger caca-utils highlight atool w3m poppler-utils mediainfo
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Setting Ranger - - - - -"
echo "- - - - - - - - - - - - - - - - -"
ranger --copy-config=rc
mkdir -p ~/.config/ranger/colorschemes
cp ~/dotfiles/ranger/dracula.py ~/.config/ranger/colorschemes/dracula.py
cp ~/dotfiles/ranger/rc.conf ~/.config/ranger/rc.conf
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - End Ranger - - - - - -"
echo "- - - - - - - - - - - - - - - - -"

