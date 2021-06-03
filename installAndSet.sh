#!/bin/bash

clear
echo "  - - - - - - VHI3- - - - - - - -"
echo "/ D O T F I L E S   M A N A G E R \\"
echo "- - - - - - - - - - - - - - - - -"

sudo apt install command-not-found apt-file
sudo apt update
sudo apt-file update
sudo apt upgrade
echo "- - - - - - - - - - - - - - - - -"
echo "    I N S T A L L   B A S I C S  "
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Intel Microcode- - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install intel-microcode
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Git - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install git
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - Ctags - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install exuberant-ctags
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - WGET- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install wget
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - CURL- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install curl
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
sudo reboot
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
sudo apt upgrade
sudo apt autoremove
cd ~
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
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - Intel® oneAPI - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
oneAPIInput=false;
echo "Do you want to install Intel® oneAPI? (y/n)"
read -n 1 oneAPIInput ; echo; echo
if [ $oneAPIInput == "y" ] || [ $oneAPIInput == "Y" ] ; then
cd ~/tmp
sudo apt autoremove
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
sudo apt update
sudo apt install intel-basekit
sudo apt install intel-hpckit
#sudo apt install intel-iotkit 
#sudo apt install intel-dlfdkit 
#sudo apt install intel-aikit 
#sudo apt install intel-renderkit
echo "source /opt/intel/oneapi/setvars.sh > /dev/null" | sudo tee -a /etc/bash.bashrc
echo "DONE"
fi
cd ~
#
sudo apt install cups conky htop xbindkeys arandr libnotify-bin multitail tree joe powerline clipit
sudo apt autoremove 
sudo systemctl enable fstrim.timer
sudo apt install dunst
sudo apt install mutt
echo "- - - - - - - - - - - - - - - - -"
echo "       Nvidia Driver             "
echo "- - - - - - - - - - - - - - - - -"
#sudo apt install ubuntu-drivers-common
#sudo ubuntu-drivers autoinstall
#
echo "- - - - - - - - - - - - - - - - -"
echo "       D O T F I L E S           "
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - Bash- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use bash dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  ln -s -f ~/dotfiles/bash/bashrc ~/.bashrc
  #ln -s -f ~/comfy_guration/dotfiles/inputrc ~/.inputrc
  #ln -s -f ~/comfy_guration/dotfiles/common/git-prompt.sh ~/.git-prompt.sh
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - VIM dotfile- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use NVIM dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  ln -s -f ~/dotfiles/vim/vimrc ~/.vimrc
  vim +PluginInstall +qall
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -i3wm dotfile - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use i3WM dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  mkdir -p ~/.config/i3/
  ln -s -f ~/dotfiles/i3/config ~/.config/i3/config
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -i3pystatus dotfile - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use i3pystatus dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  mkdir -p ~/.config/i3pystatus/
  ln -s -f ~/dotfiles/i3pystatus/i3pystatus.conf ~/.config/i3pystatus/i3pystatus.conf
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -wallpapers dotfile - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use wallpapers dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  mkdir -p ~/.config/setWallpaper/
  ln -s -f ~/dotfiles/setWallpaper/wallpapers.sh ~/.config/setWallpaper/wallpapers.sh
  cd ~/.config/setWallpaper/
  chmod +x wallpapers.sh
  cd ~
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -rofi dotfile - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use rofi dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  mkdir -p ~/.config/rofi/
  ln -s -f ~/dotfiles/rofi/config.rasi ~/.config/rofi/config.rasi
  cd ~/tmp
  git clone https://github.com/jluttine/rofi-power-menu.git
  cd rofi-power-menu/
  cp rofi-power-menu ~/.local/bin/
  cd ~
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - -  bashtop dotfile  - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use bashtop dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  cp ~/tmp/bashtop/dracula.theme ~/dotfiles/bashtop/dracula.theme
  mkdir -p ~/.config/bashtop/user_themes
  ln -s -f ~/dotfiles/bashtop/dracula.theme ~/.config/bashtop/user_themes/dracula.theme
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - -  set Monitors - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want set Monitors? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  mkdir -p ~/.config/setMonitors/
  echo "Do you use laptop? (y/n)"
  read -n 1 LAPTOP ; echo; echo
  if [ $LAPTOP == "y" ] || [ $LAPTOP == "Y" ] ; then
    ln -s -f ~/dotfiles/setMonitors/setMonitor_laptop.sh ~/.config/setMonitors/setMonitor.sh
    cd ~/.config/setMonitors/
    chmod +x setMonitor.sh
    cd ~
  fi
  if [ $LAPTOP == "n" ] || [ $LAPTOP == "N" ] ; then
    ln -s -f ~/dotfiles/setMonitors/setMonitor_TinkStation.sh ~/.config/setMonitors/setMonitor.sh
    cd ~/.config/setMonitors/
    chmod +x setMonitor.sh
    cd ~
  fi
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - -  Hyper dotfile- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use Hyper dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  ln -s -f ~/dotfiles/hyper/hyper.js ~/.hyper.js
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - Mailspring dotfile  - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use Mailspring dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/dracula/mailspring.git
  mkdir -p ~/.config/Mailspring/packages/dracula-theme
  cd mailspring
  cp -rf * ~/.config/Mailspring/packages/dracula-theme/
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - -  Telegram dotfile - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use Telegram dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/dracula/telegram.git
  cd telegram/
  mkdir -p ~/.config/telegramTheme/
  cp colors.tdesktop-theme ~/.config/telegramTheme/
  cd ~
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Dunst dotfile  - - - - -"
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo "Do you want to use Dunst dotfile? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/dracula/dunst.git
  mkdir -p ~/.config/dunst/
  cd dunst/
  cp dunstrc ~/.config/dunst/
  cd ~
fi
echo "- - - - - - - - - - - - - - - - -"
echo "         Python Packages         "
echo "- - - - - - - - - - - - - - - - -"
sudo apt install ubuntu-drivers-common
sudo ubuntu-drivers autoinstall
sudo apt install nvidia-cuda-toolkit
nvcc -V
python -m pip install -U scikit-image
python3 -m pip install -U scikit-image
python -m pip install -U scikit-learn
python3 -m pip install -U scikit-learn
python -m pip install -U statsmodels
python3 -m pip install -U statsmodels
python -m pip install -U sympy
python3 -m pip install -U sympy
pip3 install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html
pip install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - ML - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
ML=false;
echo "Do you want to compile Machine-Learning library? (y/n)"
read -n 1 ML ; echo; echo
if [ $ML == "y" ] || [ $ML == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/PacktPublishing/Hands-On-Machine-Learning-with-CPP.git
  cd Hands-On-Machine-Learning-with-CPP/env_scripts
  sudo apt install -y build-essential gdb git python python-pip libblas-dev libopenblas-dev libatlas-base-dev liblapack-dev libboost-all-dev libopencv-core3.2 libopencv-imgproc3.2 libopencv-dev libopencv-highgui3.2 libopencv-highgui-dev libhdf5-dev libjson-c-dev libx11-dev openjdk-8-jdk wget gnuplot vim python3-venv
  pip install pyyaml
  pip3 install pyyaml
  pip install typing
  pip3 install typing
  sed -i 's/442d52ba052115b32035a6e7dc6587bb6a462dec/106cafdae41834c637fe5cb63980834517a05024/g'  install_env.sh
  mkdir ~/development
  cp checkout_lib.sh ~/development
  cp install_lib.sh ~/development
  cp install_env.sh ~/development
  cp install_android.sh ~/development
  cd ~/development
  chmod 777 checkout_lib.sh
  chmod 777 install_lib.sh
  chmod 777 install_env.sh
  chmod 777 install_android.sh
  ./install_env.sh
  ./install_android.sh
  echo "DONE"
fi

