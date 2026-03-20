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
  echo 'deb [signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free' | sudo tee /etc/apt/sources.list.d/spotify.list
  curl -fsSL https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/spotify.gpg >/dev/null
  ln -sf ~/dotfiles/10-spotify/spotify.desktop ~/.local/share/applications/spotify.desktop
  sudo apt update
  sudo apt install spotify-client
  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - - - End Spotify - - - - - -"
  echo "- - - - - - - - - - - - - - - - -"
fi
