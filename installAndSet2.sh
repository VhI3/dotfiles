#!/bin/bash

echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Plugins manager - - - -"
echo "- - - - - - - - - - - - - - - - -"
#curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - -Jedi - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
pip3 install --user jedi mistune psutil setproctitle
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - i3WM- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo add-apt-repository ppa:aguignard/ppa
sudo apt update
sudo apt install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev automake libxcb-shape0-dev meson
sudo apt install xorg lightdm suckless-tools # just for minimalist
sudo apt install i3
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - i3WM-GAPS - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
mkdir -p ~/tmp
cd ~/tmp
git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps
meson build
sudo ninja -C build/ install
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - I3LOCK- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt -y install pkg-config libxcb1-dev libxcb1 libgl2ps-dev libx11-dev libglc0 libglc-dev libcairo2-dev libcairo-gobject2 libcairo2-dev libxkbfile-dev libxkbfile1 libxkbcommon-dev libxkbcommon-x11-dev libxcb-xkb-dev libxcb-dpms0-dev libxcb-damage0-dev libpam0g-dev libev-dev libxcb-image0-dev libxcb-util0-dev libxcb-composite0-dev libxcb-xinerama0-dev
sudo apt install i3lock
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - I3LOCK-Color- - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev
cd ~/tmp
git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
sudo ./install-i3lock-color.sh
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - FEH - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install feh
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - ROFI- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install rofi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - i3pystatus- - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~/tmp
pip3 install git+https://github.com/enkore/i3pystatus.git
pip3 install python-vlc
pip3 install python-dateutil
pip3 install requests
pip3 install colour
pip3 install geoip2
pip3 install netifaces
pip3 install psutil
pip3 install i3ipc
pip3 install xkbgroup
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -NM-APPLET- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install network-manager
sudo apt install wicd
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -ALSA MIXER - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install alsa-utils
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - -COMPTON- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install compton compton-conf
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - -FONTS- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
mkdir -p ~/tmp
cd ~/tmp
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cd ~/tmp
git clone https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh
cd ~
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
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - -  Hyper  - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~/tmp
wget -O hyper.deb https://releases.hyper.is/download/deb
sudo apt install ./hyper.deb
echo "- - - - - - - - - - - - - - - - -"
echo "- - - -  Mailspring - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~/tmp
wget -O mailspring.deb https://updates.getmailspring.com/download?platform=linuxDeb mailspring
sudo apt install ./mailspring.deb
echo "- - - - - - - - - - - - - - - - -"
echo "- - - -  Google Chrome- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~/tmp
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
wget https://dl.google.com/linux/linux_signing_key.pub
sudo apt-key add linux_signing_key.pub
sudo apt update
sudo apt install google-chrome-stable
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - -  XFCE4 Power Manager  - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install xfce4-power-manager
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Telegram- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install telegram-desktop 
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Volume Icon - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install volumeicon-alsa
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Sciebo- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~/tmp
wget -nv https://www.sciebo.de/install/linux/Ubuntu_18.04/Release.key -O - | sudo apt-key add -
echo 'deb https://www.sciebo.de/install/linux/Ubuntu_18.04/ /' | sudo tee -a /etc/apt/sources.list.d/owncloud.list
sudo apt update
sudo apt install sciebo-client
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Spotify - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~/tmp
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt update && sudo apt install spotify-client
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - LaTeX - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~
sudo apt-get install texlive-full texmaker kile
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - VS Code - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
cd ~/tmp
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code
sudo apt update
sudo apt upgrade
sudo apt autoremove
cd ~



sudo apt-get install pavucontrol
sudo apt install ubuntu-restricted-extras
sudo apt install chromium-codecs-ffmpeg*
sudo apt install chromium-codecs-ffmpeg
sudo apt install chromium-codecs-ffmpeg-extra 
sudo apt install libfaac-dev
sudo apt install libfaac0
sudo apt install aften
sudo apt install faac
sudo apt install libavcodec-dev
sudo apt install libavcodec57
sudo apt install libaften-dev
sudo apt install libaften0
sudo apt autoremove
sudo apt install librem-dev
sudo apt install librem0
sudo apt install pd-readanysf
