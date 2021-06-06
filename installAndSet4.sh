#!/bin/bash

echo "- - - - - - - - - - - - - - - - -"
echo "       D O T F I L E S           "
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - Bash- - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
BashINPUT=false;
echo "Do you want to use bash dotfile? (y/n)"
read -n 1 BashINPUT ; echo; echo
if [ $BashINPUT == "y" ] || [ $BashINPUT == "Y" ] ; then
  ln -s -f ~/dotfiles/bash/bashrc ~/.bashrc
  #ln -s -f ~/comfy_guration/dotfiles/inputrc ~/.inputrc
  #ln -s -f ~/comfy_guration/dotfiles/common/git-prompt.sh ~/.git-prompt.sh
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - VIM dotfile- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
VIMINPUT=false;
echo "Do you want to use NVIM dotfile? (y/n)"
read -n 1 VIMINPUT ; echo; echo
if [ $VIMINPUT == "y" ] || [ $VIMINPUT == "Y" ] ; then
  ln -s -f ~/dotfiles/vim/vimrc ~/.vimrc
  vim +PluginInstall +qall
  mkdir -p ~/.vim/autoload/
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -i3wm dotfile - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
i3wmINPUT=false;
echo "Do you want to use i3WM dotfile? (y/n)"
read -n 1 i3wmINPUT ; echo; echo
if [ $i3wmINPUT == "y" ] || [ $i3wmINPUT == "Y" ] ; then
  mkdir -p ~/.config/i3/
  ln -s -f ~/dotfiles/i3/config ~/.config/i3/config
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -i3pystatus dotfile - - -"
echo "- - - - - - - - - - - - - - - - -"
i3pystatusINPUT=false;
echo "Do you want to use i3pystatus dotfile? (y/n)"
read -n 1 i3pystatusINPUT ; echo; echo
if [ $i3pystatusINPUT == "y" ] || [ $i3pystatusINPUT == "Y" ] ; then
  mkdir -p ~/.config/i3pystatus/
  ln -s -f ~/dotfiles/i3pystatus/i3pystatus.conf ~/.config/i3pystatus/i3pystatus.conf
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -wallpapers dotfile - - -"
echo "- - - - - - - - - - - - - - - - -"
wallpapersINPUT=false;
echo "Do you want to use wallpapers dotfile? (y/n)"
read -n 1 wallpapersINPUT ; echo; echo
if [ $wallpapersINPUT == "y" ] || [ $wallpapersINPUT == "Y" ] ; then
  mkdir -p ~/.config/setWallpaper/
  ln -s -f ~/dotfiles/setWallpaper/wallpapers.sh ~/.config/setWallpaper/wallpapers.sh
  cd ~/.config/setWallpaper/
  chmod +x wallpapers.sh
  cd ~
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -rofi dotfile - - -"
echo "- - - - - - - - - - - - - - - - -"
rofiINPUT=false;
echo "Do you want to use rofi dotfile? (y/n)"
read -n 1 rofiINPUT ; echo; echo
if [ $rofiINPUT == "y" ] || [ $rofiINPUT == "Y" ] ; then
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
bashtopINPUT=false;
echo "Do you want to use bashtop dotfile? (y/n)"
read -n 1 bashtopINPUT ; echo; echo
if [ $bashtopINPUT == "y" ] || [ $bashtopINPUT == "Y" ] ; then
  cp ~/tmp/bashtop/dracula.theme ~/dotfiles/bashtop/dracula.theme
  mkdir -p ~/.config/bashtop/user_themes
  ln -s -f ~/dotfiles/bashtop/dracula.theme ~/.config/bashtop/user_themes/dracula.theme
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - -  set Monitors - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
MonitorsINPUT=false;
echo "Do you want set Monitors? (y/n)"
read -n 1 MonitorsINPUT ; echo; echo
if [ $MonitorsINPUT == "y" ] || [ $MonitorsINPUT == "Y" ] ; then
  mkdir -p ~/.config/setMonitors/
  LAPTOP=false;
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
HyperINPUT=false;
echo "Do you want to use Hyper dotfile? (y/n)"
read -n 1 HyperINPUT ; echo; echo
if [ $HyperINPUT == "y" ] || [ $HyperINPUT == "Y" ] ; then
  ln -s -f ~/dotfiles/hyper/hyper.js ~/.hyper.js
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - Mailspring dotfile  - - - - -"
echo "- - - - - - - - - - - - - - - - -"
MailspringINPUT=false;
echo "Do you want to use Mailspring dotfile? (y/n)"
read -n 1 MailspringINPUT ; echo; echo
if [ $MailspringINPUT == "y" ] || [ $MailspringINPUT == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/dracula/mailspring.git
  mkdir -p ~/.config/Mailspring/packages/dracula-theme
  cd mailspring
  cp -rf * ~/.config/Mailspring/packages/dracula-theme/
fi
echo "- - - - - - - - - - - - - - - - -"
echo "- - -  Telegram dotfile - - - - -"
echo "- - - - - - - - - - - - - - - - -"
TelegramINPUT=false;
echo "Do you want to use Telegram dotfile? (y/n)"
read -n 1 TelegramINPUT ; echo; echo
if [ $TelegramINPUT == "y" ] || [ $TelegramINPUT == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/dracula/telegram.git
  cd telegram/
  mkdir -p ~/.config/telegramTheme/
  cp colors.tdesktop-theme ~/.config/telegramTheme/
  cd ~
fi
echo "- - - - - - - - - - - - - - - - -"
echo "          Dunst dotfile          "
echo "- - - - - - - - - - - - - - - - -"
DunstINPUT=false;
echo "Do you want to use Dunst dotfile? (y/n)"
read -n 1 DunstINPUT ; echo; echo
if [ $DunstINPUT == "y" ] || [ $DunstINPUT == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/dracula/dunst.git
  mkdir -p ~/.config/dunst/
  cd dunst/
  cp dunstrc ~/.config/dunst/
  cd ~
fi
echo "- - - - - - - - - - - - - - - - -"
echo "     matrixlock dotfile          "
echo "- - - - - - - - - - - - - - - - -"
matrixlockINPUT=false;
echo "Do you want to use Dunst dotfile? (y/n)"
read -n 1 matrixlockINPUT ; echo; echo
if [ $matrixlockINPUT == "y" ] || [ $matrixlockINPUT == "Y" ] ; then
  cd ~/tmp
  git clone https://github.com/mherrmann/matrixlock.git
  mkdir -p ~/.config/matrixlock/
  cd matrixlock/
  cp matrixlock.py ~/.config/matrixlock/
  cd ~
fi
echo "- - - - - - - - - - - - - - - - -"
echo "         Python Packages         "
echo "- - - - - - - - - - - - - - - - -"
sudo apt install ubuntu-drivers-common
PyPackINPUT=false;
echo "Do you want to install Python Packages? (y/n)"
read -n 1 PyPackINPUT ; echo; echo
if [ $PyPackINPUT == "y" ] || [ $PyPackINPUT == "Y" ] ; then
python -m pip install -U scikit-image
python3 -m pip install -U scikit-image
python -m pip install -U scikit-learn
python3 -m pip install -U scikit-learn
python -m pip install -U statsmodels
python3 -m pip install -U statsmodels
python -m pip install -U sympy
python3 -m pip install -U sympy
python3 -m pip install ninja pyyaml mkl mkl-include setuptools cmake cffi typing
pip3 install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html
pip install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html
python3 -m pip install tensorflow
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
