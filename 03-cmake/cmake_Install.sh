#!/bin/bash
cmakeInstall=false
echo "Do you want to install cmake-3.30.0-rc1? (y/n)"
read -n 1 cmakeInstall
echo
echo
if [ $cmakeInstall == "y" ] || [ $cmakeInstall == "Y" ]; then
	echo "- - - - - - - - - - - - - - - - -"
	echo "- - - - - Cmake-3.30.0-rc1- - - -"
	echo "- - - - - - - - - - - - - - - - -"
	sudo apt remove --purge cmake
	sudo apt update
	sudo apt upgrade
	sudo apt autoremove
	sudo apt install build-essential libssl-dev
	wget https://github.com/Kitware/CMake/releases/download/v3.30.0-rc1/cmake-3.30.0-rc1.tar.gz -P ~/tmp/
	tar -zxvf ~/tmp/cmake-3.30.0-rc1.tar.gz -C ~/tmp/
	cd ~/tmp/cmake-3.30.0-rc1/
	./bootstrap
	make -j4
	sudo make install
	cd ~
	rm -rf ~/tmp/cmake*
	echo "- - - - - - - - - - - - - - - - -"
	echo "- - - - - - End Cmake - - - - - -"
	echo "- - - - - - - - - - - - - - - - -"
fi

