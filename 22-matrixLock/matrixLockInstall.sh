#!/bin/bash
echo "- - - - - - - - - - - - - - - - -"
echo "     matrixlock dotfile          "
echo "- - - - - - - - - - - - - - - - -"
matrixlockINPUT=false
echo "Do you want to use Dunst dotfile? (y/n)"
read -n 1 matrixlockINPUT
echo
echo
if [ $matrixlockINPUT == "y" ] || [ $matrixlockINPUT == "Y" ]; then
  cd ~/tmp
  git clone https://github.com/mherrmann/matrixlock.git
  mkdir -p ~/.config/matrixlock/
  cd matrixlock/
  cp matrixlock.py ~/.config/matrixlock/
  cd ~
fi
