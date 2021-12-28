#!/bin/bash
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - -VIM- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Install VIM- - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt upgrade
sudo apt autoremove 
sudo apt install vim
sudo apt install python3-dev python3-pip
sudo apt install vim-gtk3 vim-nox
sudo apt install vim-youcompleteme
vim-addon-manager install youcompleteme
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Setting VIM- - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
mkdir -p ~/.vim/pack/themes/start
cd ~/.vim/pack/themes/start
git clone https://github.com/dracula/vim.git dracula
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - End VIM - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"

