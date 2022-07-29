#!/bin/bash
RofiFehInstall=false
echo "Do you want to install RofiFeh? (y/n)"
read -n 1 RofiFehInstall
echo
echo
if [ $RofiFehInstall == "y" ] || [ $RofiFehInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - i3WM-GAPS - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    cd ~/tmp
    git clone https://www.github.com/Airblader/i3 i3-gaps
    cd i3-gaps
    meson build
    sudo ninja -C build/ install
    cd ~
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - I3LOCK- - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
