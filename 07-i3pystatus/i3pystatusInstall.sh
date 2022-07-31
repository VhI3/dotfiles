#!/bin/bash
i3pystatusInstall=false
echo "Do you want to install i3pystatus? (y/n)"
read -n 1 i3pystatusInstall
echo
echo
if [ $i3pystatusInstall == "y" ] || [ $i3pystatusInstall == "Y" ]; then
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - i3pystatus - - - - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
    sudo apt update
    sudo apt upgrade
    sudo apt autoremove
    sudo apt install python3-pip
    python3 -m pip install git+https://github.com/enkore/i3pystatus.git
    python3 -m pip install python-vlc
    python3 -m pip install python-dateutil
    python3 -m pip install requests
    python3 -m pip install colour
    python3 -m pip install geoip2
    python3 -m pip install netifaces
    python3 -m pip install psutil
    python3 -m pip install i3ipc
    python3 -m pip install xkbgroup
    mkdir -p ~/.config/i3pystatus/
    ln -s -f ~/dotfiles/10-i3pystatus/i3pystatus.conf ~/.config/i3pystatus/i3pystatus.conf
    echo "- - - - - - - - - - - - - - - - -"
    echo "- - - - - - End i3pystatus - - - - - -"
    echo "- - - - - - - - - - - - - - - - -"
fi
