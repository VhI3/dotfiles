#!/bin/bash

# Install qt5 on linux
sudo apt install qtbase5-dev qtbase5-dev-tools libqt5svg5-dev and qttools5-dev-tools

# Install gnuplot
# Download gnuplot to ~/tmp
wget -P ~/tmp https://sourceforge.net/projects/gnuplot/files/gnuplot/6.0.2/gnuplot-6.0.2.tar.gz/download
# Extract the tar file
cd ~/tmp/
tar -zxvf gnuplot-6.0.2.tar.gz
cd gnuplot-6.0.2
./configure --with-qt=qt5
make -j
make check
sudo make install

# Remove remaining files
rm -rf ~/tmp/gnuplot-6.0.2
