#!/bin/bash
SpotifyInstall=false
echo "Do you want to install Spotify? (y/n)"
read -n 1 SpotifyInstall
echo
echo
if [ $SpotifyInstall == "y" ] || [ $SpotifyInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - Spotify- - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 4773BD5E130D1D45
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update 
    sudo apt install spotify-client
    sudo apt upgrade
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End Spotify - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
