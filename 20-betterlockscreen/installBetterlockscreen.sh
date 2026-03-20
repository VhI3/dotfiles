#!/bin/bash

echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Betterlockscreen- - - -"
echo "- - - - - - - - - - - - - - - - -"
mkdir -p ~/tmp
cd ~/tmp
git clone https://github.com/pavanjadhaw/betterlockscreen
cd betterlockscreen
mkdir -p ~/.config/betterlockscreen
mv betterlockscreen ~/.config/betterlockscreen
cd ~/.config/betterlockscreen
chmod +x ./betterlockscreen
cd ~
sudo apt install imagemagick-6.q16
sudo apt install bc
cd ~/tmp
wget https://wallpapercave.com/uwp/uwp1103730.jpeg
cd ~/.config/betterlockscreen
./betterlockscreen -u ~/tmp/uwp1103730.jpeg
