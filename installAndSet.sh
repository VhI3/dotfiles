#!/bin/bash
# TODO: install cmus if
# TODO: cmus theme
# TODO: install vis if
# TODO: vis theme

clear
echo "  - - - - - - VHI3- - - - - - - -"
echo "/ D O T F I L E S   M A N A G E R \\"
echo "- - - - - - - - - - - - - - - - -"

# Check if using pacman (arch) or apt (debian)
sudo apt update
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
echo "- - - - - - - - - - - - - - - - -"
echo "       S O F T W A R E S         "
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - URXVT - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install rxvt-unicode-256color
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - XCLIP - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install xclip
echo "- - - - - - - - - - - - - - - - -"
echo "- - - -Plugins dependencies - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install software-properties-common
#sudo apt install python-software-properties
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - VIM - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install vim
sudo apt install python-dev python-pip python3-dev python3-pip
sudo apt install vim-gtk3 vim-nox
sudo apt install vim-youcompleteme
sudo apt upgrade
sudo apt autoremove
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
#    cd ~/tmp
#    git clone git@github.com:karulont/i3lock-blur.git
#    cd i3lock-blur
#    make
#    sudo make install
#    cd ~
#  fi
#fi
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
#pip3 install basiciw
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
sudo apt install compton
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - -FONTS- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
mkdir -p ~/tmp
cd ~/tmp
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cd ~
#git clone https://github.com/ryanoasis/nerd-fonts.git
#cd nerd-fonts
#./install.sh
#cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Betterlockscreen- - - -"
echo "- - - - - - - - - - - - - - - - -"
mkdir -p ~/tmp
cd ~/tmp
git clone https://github.com/pavanjadhaw/betterlockscreen
cd betterlockscreen
mv betterlockscreen ~/.config/i3/
cd ~/.config/i3/
chmod +x ./betterlockscreen
cd ~
sudo apt install imagemagick-6.q16
sudo apt install bc
cd ~/tmp
wget https://wallpapercave.com/uwp/uwp1103730.jpeg
cd ~/.config/i3/
./betterlockscreen -u ~/tmp/uwp1103730.jpeg
cd ~
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
sudo apt-get install cups
sudo apt-get install conky htop
sudo apt-get install xbindkeys
sudo apt-get install arandr
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
  #echo "source /opt/intel/oneapi/setvars.sh > /dev/null" > /etc/profile.d/intel-oneAPI.sh
  echo "source /opt/intel/oneapi/setvars.sh > /dev/null" | sudo tee -a /etc/profile.d/intel-oneAPI.sh
  echo "DONE"
fi
echo "- - - - - - - - - - - - - - - - -"
echo "       D O T F I L E S           "
echo "- - - - - - - - - - - - - - - - -"
INPUT=false;
echo
echo "Do you want to use dotfiles from ~/comfy_guration/dotfiles? (y/n)"
read -n 1 INPUT ; echo; echo
if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
echo "- - Activate laptop dotfiles- - -"
echo "- - - - - - - - - - - - - - - - -"
  LAPTOP=false;
  INPUT=false;
  echo "Are you on a laptop (y/n)"
  read -n 1 INPUT ; echo; echo
  if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
    LAPTOP=true;
  fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - Bash- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
  echo "Do you want to use bash dotfile? (y/n)"
  read -n 1 INPUT ; echo; echo
  if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
    ln -s -f ~/comfy_guration/dotfiles/laptop/bashrc_laptop ~/.bashrc
 #   ln -s -f ~/comfy_guration/dotfiles/inputrc ~/.inputrc
    ln -s -f ~/comfy_guration/dotfiles/common/git-prompt.sh ~/.git-prompt.sh
    echo "DONE"
  fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - NVIM dotfile- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
  INPUT=false;
  echo "Do you want to use NVIM dotfile? (y/n)"
  read -n 1 INPUT ; echo; echo
  if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
#    mkdir -p ~/.config
    mkdir -p ~/.config/nvim
    ln -s -f ~/comfy_guration/dotfiles/common/init.vim ~/.config/nvim/init.vim
#    ln -s -f ~/comfy_guration/dotfiles/ctagsrc ~/.ctags
#    ln -s -f ~/comfy_guration/dotfiles/custom_snips ~/.config/nvim/UltiSnips
    echo "DONE"
  fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -i3wm dotfile - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
  INPUT=false;
  echo "Do you want to use i3WM dotfile? (y/n)"
  read -n 1 INPUT ; echo; echo
  if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
#    mkdir -p ~/.config
#    mkdir -p ~/.config/i3/
    if [ $LAPTOP ] ; then
      ln -s -f ~/comfy_guration/dotfiles/laptop/i3_laptop ~/.config/i3/config
      echo "DONE"
    fi
  fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - -  polybar dotfile  - - - - -"
echo "- - - - - - - - - - - - - - - - -"
  INPUT=false;
  echo "Do you want to use polybar dotfile? (y/n)"
  read -n 1 INPUT ; echo; echo
  if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
#    mkdir -p ~/.config
    mkdir -p ~/.config/polybar/
    if [ $LAPTOP ] ; then
      ln -s -f ~/comfy_guration/dotfiles/laptop/polybar_laptop ~/.config/polybar/config
      echo "DONE"
    fi
  fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - URXVT dotfile - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
  INPUT=false;
  echo "Do you want to use URXVT dotfile? (y/n)"
  read -n 1 INPUT ; echo; echo
  if [ $INPUT == "y" ] || [ $INPUT == "Y" ] ; then
    ln -s -f ~/comfy_guration/dotfiles/Xresources ~/.Xresources
    xrdb ~/.Xresources
    sudo cp ~/comfy_guration/scripts/clipboard /usr/lib/urxvt/perl/
    echo "DONE"
  fi
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

