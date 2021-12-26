#!/bin/bash
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Ninja-1.10.2- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~/tmp/
wget https://github.com/ninja-build/ninja/archive/refs/tags/v1.10.2.tar.gz
tar -xvf v1.10.2.tar.gz
cd ninja-1.10.2/
mkdir build
cd build
cmake ..
make -j4
sudo make install
rm -rf ~/tmp/v1.10.*
rm -rf ~/tmp/ninja*
cd ~/
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - End Ninja - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
