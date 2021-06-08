#!/bin/bash

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
