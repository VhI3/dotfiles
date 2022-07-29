#!/bin/bash
clear
echo "- - - - - - - VHI3- - - - - - - - -"
echo "/ D O T F I L E S   M A N A G E R \\"
echo "- - - - - - - - - - - - - - - - - -"
. ~/dotfiles/1-preInstall/installAndSet0.sh
. ~/dotfiles/2-GCC/gcc.sh
. ~/dotfiles/3-cmake/cmakeInstall.sh
. ~/dotfiles/4-rust/rustInstall.sh
. ~/dotfiles/5-font/fontInstall.sh
. ~/dotfiles/6-spotify/spotifyInstall.sh
. ~/dotfiles/7-alacritty/AlacrittyInstall.sh
