#!/bin/bash
RofiFehInstall=false
echo "Do you want to install RofiFeh? (y/n)"
read -n 1 RofiFehInstall
echo
echo
if [ $RofiFehInstall == "y" ] || [ $RofiFehInstall == "Y" ]; then
  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - - - i3WM-GAPS - - - - - -"
  echo "- - - - - - - - - - - - - - - - -"
  sudo apt install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev automake libxcb-shape0-dev meson
  cd ~/tmp
  git clone https://www.github.com/Airblader/i3 i3-gaps
  cd i3-gaps
  meson build
  sudo ninja -C build/ install
  cd ~
  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - - - I3LOCK- - - - - - - -"
  echo "- - - - - - - - - - - - - - - - -"
fi

# TODO: Check which computer is it based on hostname
#
