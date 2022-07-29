#!/bin/bash
rustInstall=false;
echo "Do you want to install Rust? (y/n)"
read -n 1 rustInstall ; echo; echo
if [ $rustInstall == "y" ] || [ $rustInstall == "Y" ] ; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - Rust- - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    cd ~/tmp
    curl https://sh.rustup.rs -sSf | sh
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End Rust - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi