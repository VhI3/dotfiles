#!/bin/bash
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - -VIM- - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Install VIM- - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
# remove current vim
sudo apt-get remove --purge vim vim-runtime vim-gnome vim-tiny vim-gui-common
# removes current link for vim
sudo rm -rf /usr/local/share/vim /usr/bin/vim
# add ppa for newest version of ruby (currently, as of 06/06/2017, ruby v2.4)
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt update
# installs everything needed to make/configure/build Vim
sudo apt install libncurses5-dev libgnome2-dev libgnomeui-dev \
libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
libcairo2-dev libx11-dev libxpm-dev libxt-dev  \
python3-dev ruby-dev lua5.3 lua5.3-dev libperl-dev 
sudo update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.3
sudo update-alternatives --install /usr/bin/luac luac /usr/bin/luac5.3
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
sudo ./configure --prefix=/usr/local \
--enable-multibyte \
--enable-perlinterp=dynamic \
--enable-rubyinterp=dynamic \
--with-ruby-command=/usr/bin/ruby \
--enable-python3interp=yes \
--with-python3-config-dir=/usr/lib/python3.8/config-3.6m-x86_64-linux-gnu/ \
--enable-luainterp \
--with-luajit \
--enable-cscope \
--enable-gui=auto \
--with-features=huge \
--with-x \
--enable-fontset \
--enable-largefile \
--disable-netbeans \
--with-compiledby="VHI3" \
--enable-fail-if-missing
# one /usr/bin folder
make -j4
sudo make install
sudo apt install vim-nox
sudo apt install mono-complete golang nodejs default-jdk npm
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - -Setting VIM- - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"
echo "- - - - - End VIM - - - - - - - -"
echo "- - - - - - - - - - - - - - - - -"

