#!/bin/bash


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
