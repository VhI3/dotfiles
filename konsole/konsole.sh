#!/bin/bash
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Konsole - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Install Konsole- - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install konsole keditbookmarks
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Setting Konsole- - - - -"
echo "- - - - - - - - - - - - - - - - -"
mkdir -p ~/.local/share/konsole
cp ~/dotfiles/konsole/Dracula.colorscheme ~/.local/share/konsole/Dracula.colorscheme
echo "Go to Konsole > Settings > Edit Current Profile… > Appearance tab"
echo "Select the Dracula scheme from the Color Schemes & Background… pane"
konsole
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - End Konsole - - - - - -"
echo "- - - - - - - - - - - - - - - - -"

