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
source /opt/intel/oneapi/setvars.sh
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
sudo apt install xautolock
echo "- - - - - - - - - - - - - - - - -"
echo "       Nvidia Driver             "
echo "- - - - - - - - - - - - - - - - -"
sudo apt-get install freeglut3 freeglut3-dev libxi-dev libxmu-dev dkms
#sudo apt install ubuntu-drivers-common 
#sudo ubuntu-drivers autoinstall
#sudo apt install nvidia-cuda-toolkit
#sudo apt install libcupti-dev

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /"
sudo apt-get update

wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb

sudo apt install ./nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo apt-get update

wget https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/libnvinfer7_7.1.3-1+cuda11.0_amd64.deb
sudo apt install ./libnvinfer7_7.1.3-1+cuda11.0_amd64.deb
sudo apt-get update

# Install development and runtime libraries (~4GB)
sudo apt-get install --no-install-recommends \
    cuda-11-0 \
    libcudnn8=8.0.4.30-1+cuda11.0  \
    libcudnn8-dev=8.0.4.30-1+cuda11.0

sudo reboot

sudo apt-get install -y --no-install-recommends libnvinfer7=7.1.3-1+cuda11.0 \
    libnvinfer-dev=7.1.3-1+cuda11.0 \
    libnvinfer-plugin7=7.1.3-1+cuda11.0





