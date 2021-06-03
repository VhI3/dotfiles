#!/bin/bash

clear
echo "  - - - - - - VHI3- - - - - - - -"
echo "/ D O T F I L E S   M A N A G E R \\"
echo "- - - - - - - - - - - - - - - - -"

echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Python- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install python
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Python3 - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install python3
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - PIP - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install python-pip
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - PIP3- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install python3-pip
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - NPM - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install npm
echo "- - - - - - - - - - - - - - - - -"
echo "       S O F T W A R E S         "
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Konsole - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install konsole
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - XCLIP - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install xclip
echo "- - - - - - - - - - - - - - - - -"
echo "- - - -Plugins dependencies - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install software-properties-common
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Bashtop - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo add-apt-repository ppa:bashtop-monitor/bashtop
sudo apt update
sudo apt install bashtop
mkdir -p ~/tmp
cd ~/tmp
git clone https://github.com/dracula/bashtop.git
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Cmake-3.20.2- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install build-essential libssl-dev
cd ~/tmp
wget https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz
tar -zxvf cmake-3.20.2.tar.gz
cd cmake-3.20.2
./bootstrap
make -j4
sudo make install
wget https://github.com/ninja-build/ninja/archive/refs/tags/v1.10.2.tar.gz
tar -xvf v1.10.2.tar.gz
cd ninja-1.10.2/
mkdir build
cd build
cmake ..
make -j4
sudo make install
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Media Codecs- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo add-apt-repository multiverse
sudo apt install ubuntu-restricted-extras
sudo apt-get install libxvidcore4 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-alsa gstreamer1.0-fluendo-mp3 gstreamer1.0-libav 
sudo apt install vlc
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - -Ranger - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt update
sudo apt install ranger caca-utils highlight atool w3m poppler-utils mediainfo
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - VIM - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install vim
sudo apt install python-dev python-pip python3-dev python3-pip
sudo apt install vim-gtk3 vim-nox
sudo apt install vim-youcompleteme
vim-addon-manager install youcompleteme
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
mkdir -p ~/.vim/pack/themes/start
cd ~/.vim/pack/themes/start
git clone https://github.com/dracula/vim.git dracula
sudo apt update
sudo apt upgrade
sudo apt autoremove
cd ~
