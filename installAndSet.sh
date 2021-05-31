#!/bin/bash

clear
echo "  - - - - - - VHI3- - - - - - - -"
echo "/ D O T F I L E S   M A N A G E R \\"
echo "- - - - - - - - - - - - - - - - -"

# Check if using pacman (arch) or apt (debian)
sudo apt install command-not-found apt-file
sudo apt update
sudo apt-file update
echo "- - - - - - - - - - - - - - - - -"
echo "    I N S T A L L   B A S I C S  "
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Intel Microcode- - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install intel-microcode
sudo apt install command-not-found apt-file
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
echo "- - - -Plugins dependencies - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install software-properties-common
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - VIM - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install vim
sudo apt install python-dev python-pip python3-dev python3-pip
sudo apt install vim-gtk3 vim-nox
sudo apt install vim-youcompleteme
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
sudo apt install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev automake libxcb-shape0-dev
sudo apt install xorg lightdm suckless-tools
sudo apt install i3
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - i3WM-GAPS - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
mkdir -p ~/tmp
cd ~/tmp
sudo apt install meson
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
git clone https://github.com/Raymo111/i3lock-cd i3lock-color
color
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
echo "- - - -  XFCE4 Power Manager  - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install xfce4-power-manager
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Volume Icon - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install volumeicon-alsa
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Sciebo- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
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
oneAPI=false;
echo "Do you want to install Intel® oneAPI? (y/n)"
read -n 1 ML ; echo; echo
if [ $oneAPI == "y" ] || [ $oneAPI == "Y" ] ; then
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

  echo "source /opt/intel/oneapi/setvars.sh > /dev/null" | sudo tee -a /etc/profile.d/intel-oneAPI.sh
  echo "DONE"
fi
#
sudo apt-get install cups
sudo apt-get install conky htop
sudo apt-get install xbindkeys
sudo apt-get install arandr
sudo apt install libnotify-bin
sudo apt install multitail
sudo apt install tree joe
sudo apt install powerline
sudo systemctl enable fstrim.timer
sudo apt install clipit
#
echo "- - - - - - - - - - - - - - - - -"
echo "       D O T F I L E S           "
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - Bash- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
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
    chmod +x setMonitor_laptop.sh
    cd ~
  fi
  if [ $LAPTOP == "n" ] || [ $LAPTOP == "N" ] ; then
    ln -s -f ~/dotfiles/setMonitors/setMonitor_TinkStation.sh ~/.config/setMonitors/setMonitor.sh
    cd ~/.config/setMonitors/
    chmod +x setMonitor_TinkStation.sh
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
echo "- - - - ML - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
ML=false;
echo "Do you want to compile Machine-Learning library? (y/n)"
read -n 1 ML ; echo; echo
if [ $ML == "y" ] || [ $ML == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/PacktPublishing/Hands-On-Machine-Learning-with-CPP.git
  cd Hands-On-Machine-Learning-with-CPP/env_scripts
  sudo apt install -y build-essential gdb git cmake cmake-curses-gui python python-pip libblas-dev libopenblas-dev libatlas-base-dev liblapack-dev libboost-all-dev libopencv-core3.2 libopencv-imgproc3.2 libopencv-dev libopencv-highgui3.2 libopencv-highgui-dev libhdf5-dev libjson-c-dev libx11-dev openjdk-8-jdk wget ninja-build gnuplot vim python3-venv
  pip install pyyaml
  pip install typing
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

