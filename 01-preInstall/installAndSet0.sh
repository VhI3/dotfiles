#!/bin/bash
basicInstall=false;
echo "Do you want install some basic software? (y/n)"
read -n 1 basicInstall ; echo; echo
if [ $basicInstall == "y" ] || [ $basicInstall == "Y" ] ; then
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
fi