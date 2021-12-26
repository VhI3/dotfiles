#!/bin/bash
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Cmake-3.22.1- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt remove --purge cmake
sudo apt update
sudo apt upgrade 
sudo apt autoremove
sudo apt install build-essential libssl-dev
wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1.tar.gz -P ~/tmp/
tar -zxvf ~/tmp/cmake-3.22.1.tar.gz -C ~/tmp/
rm -rf ~/tmp/cmake-3.22.1.tar.gz
cd ~/tmp/cmake-3.22.1/
./bootstrap
make -j4
sudo make install
cd ~
rm -rf ~/tmp/cmake*
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - End Cmake - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
