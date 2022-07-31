#!/bin/bash
gccInstall=false;
echo "Do you want to install gcc-10/11? (y/n)"
read -n 1 gccInstall ; echo; echo
if [ $gccInstall == "y" ] || [ $gccInstall == "Y" ] ; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - Install Gcc10 - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt install software-properties-common
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    sudo apt install gcc-10 g++-10
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10 --slave /usr/bin/gcov gcov /usr/bin/gcov-10
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End Gcc10 - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi