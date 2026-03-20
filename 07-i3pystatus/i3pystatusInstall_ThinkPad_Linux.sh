#!/bin/bash

i3pystatusInstall=false
echo "Do you want to install i3pystatus? (y/n)"
read -n 1 i3pystatusInstall
echo
if [ $i3pystatusInstall == "y" ] || [ $i3pystatusInstall == "Y" ]; then
  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - - i3pystatus - - - - - - - - -"
  echo "- - - - - - - - - - - - - - - - -"
  sudo apt update
  sudo apt upgrade -y
  sudo apt autoremove -y

  # Install Python3 and virtual environment tools
  sudo apt install -y python3 python3-venv python3-pip

  # Create a virtual environment for i3pystatus
  echo "Creating a virtual environment for i3pystatus..."
  mkdir -p ~/.config/i3pystatus/venv
  python3 -m venv ~/.config/i3pystatus/venv

  # Activate the virtual environment
  source ~/.config/i3pystatus/venv/bin/activate

  # Install i3pystatus and dependencies in the virtual environment
  echo "Installing i3pystatus and dependencies in the virtual environment..."
  pip install --upgrade pip
  pip install git+https://github.com/enkore/i3pystatus.git
  pip install python-vlc python-dateutil requests colour geoip2 netifaces psutil i3ipc xkbgroup

  # Symlink the configuration file
  ln -s -f ~/dotfiles/07-i3pystatus/i3pystatus_ThinkPad_Linux.config ~/.config/i3pystatus/i3pystatus.conf
  # Deactivate the virtual environment
  deactivate

  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - - - End i3pystatus - - - - - -"
  echo "- - - - - - - - - - - - - - - - -"
fi
