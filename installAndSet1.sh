#!/bin/bash

clear
echo "  - - - - - - VHI3- - - - - - - -"
echo "/ D O T F I L E S   M A N A G E R \\"
echo "- - - - - - - - - - - - - - - - -"

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
echo "- - - -Plugins dependencies - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install software-properties-common
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
echo "- - - - - Cmake-3.20.2- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install build-essential libssl-dev
cd ~/tmp
wget https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz
tar -zxvf cmake-3.20.2.tar.gz
cd cmake-3.20.2
./bootstrap
make -j4
sudo make install
wget https://github.com/ninja-build/ninja/archive/refs/tags/v1.10.2.tar.gz
tar -xvf v1.10.2.tar.gz
cd ninja-1.10.2/
mkdir build
cd build
cmake ..
make -j4
sudo make install
cd ~
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Install Gcc10- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt install software-properties-common
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt install gcc-8 g++-8 gcc-9 g++-9 gcc-10 g++-10
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10 --slave /usr/bin/gcov gcov /usr/bin/gcov-10
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8 --slave /usr/bin/gcov gcov /usr/bin/gcov-8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 70 --slave /usr/bin/g++ g++ /usr/bin/g++-7 --slave /usr/bin/gcov gcov /usr/bin/gcov-7

echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - Media Codecs- - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo add-apt-repository multiverse
sudo apt install ubuntu-restricted-extras
sudo apt-get install libxvidcore4 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-alsa gstreamer1.0-fluendo-mp3 gstreamer1.0-libav 
sudo apt install vlc
sudo sed -i 's/resample-method = speex-float-1/resample-method = ffmpeg/g'  /etc/pulse/daemon.conf
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - -Ranger - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
sudo apt update
sudo apt install ranger caca-utils highlight atool w3m poppler-utils mediainfo
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - VIM - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
# remove current vim
sudo apt-get remove --purge vim vim-runtime vim-gnome vim-tiny vim-gui-common
# removes current link for vim
sudo rm -rf /usr/local/share/vim /usr/bin/vim
# add ppa for newest version of ruby (currently, as of 06/06/2017, ruby v2.4)
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get update
# installs everything needed to make/configure/build Vim
#sudo apt-get -y install liblua5.1-dev luajit libluajit-5.1 python-dev python3-dev ruby-dev ruby2.5 ruby2.5-dev libperl-dev libncurses5-dev libatk1.0-dev libx11-dev libxpm-dev libxt-dev
sudo apt-get install libncurses5-dev libgnome2-dev libgnomeui-dev \
libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
python3-dev ruby-dev lua5.3 lua5.3-dev libperl-dev git

sudo update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.3
sudo update-alternatives --install /usr/bin/luac luac /usr/bin/luac5.3
#Optional: so vim can be uninstalled again via `dpkg -r vim`
sudo apt-get -y install checkinstall
# clones vim repository so we can build it from scratch
cd ~/tmp
git clone https://github.com/vim/vim
cd vim
git pull && git fetch
# In case Vim was already installed. This can throw an error if not installed, 
# it's the nromal behaviour. That's no need to worry about it
cd src
make distclean
cd ..
# update to use the correct python 2.7/3.x config path also change 'YOUR NAME' to
# your real name
sudo ./configure --prefix=/usr/local \
--enable-multibyte \
--enable-perlinterp=dynamic \
--enable-rubyinterp=dynamic \
--with-ruby-command=/usr/bin/ruby \
--enable-pythoninterp=yes \
--with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu/ \
--enable-python3interp=yes \
--with-python3-config-dir=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu/ \
--enable-luainterp \
--with-luajit \
--enable-cscope \
--enable-gui=auto \
--with-features=huge \
--with-x \
--enable-fontset \
--enable-largefile \
--disable-netbeans \
--with-compiledby="VaHaB" \
--enable-fail-if-missing
# one /usr/bin folder
make -j4
sudo make install
sudo apt install vim-nox
sudo apt install mono-complete golang nodejs default-jdk npm
#sudo add-apt-repository ppa:jonathonf/vim
#sudo apt update
#sudo apt install vim
#sudo apt install python-dev python-pip python3-dev python3-pip
#sudo apt install vim-gtk3 vim-nox
#sudo apt install vim-youcompleteme
#vim-addon-manager install youcompleteme
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
mkdir -p ~/.vim/pack/themes/start
cd ~/.vim/pack/themes/start
git clone https://github.com/dracula/vim.git dracula
#cd ~/.vim/bundle
#git clone https://github.com/ycm-core/YouCompleteMe.git
#cd YouCompleteMe/
#git submodule update --init --recursive
#/usr/bin/python3.6 install.py --all

cd ~/tmp
wget -O - https://raw.githubusercontent.com/hmybmny/vimrc/master/install-vim-plugins | sh



sudo apt update
sudo apt upgrade
sudo apt autoremove
cd ~
