#!/bin/bash
ninjaInstall=false
echo "Do you want to install ninja? (y/n)"
read -n 1 ninjaInstall
echo
echo
if [ $ninjaInstall == "y" ] || [ $ninjaInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - ninja - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    cd ~/tmp
    wget https://github.com/ninja-build/ninja/archive/refs/tags/v1.11.0.tar.gz
    tar -xvf v1.11.0.tar.gz
    cd ninja-1.11.0/
    mkdir build
    cd build
    cmake ..
    make -j4
    sudo make install
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End ninja - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
