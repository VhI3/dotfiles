sudo apt install liblua5.1-* lua5.1
wget https://luarocks.org/releases/luarocks-3.12.2.tar.gz
tar zxpf luarocks-3.12.2.tar.gz
cd luarocks-3.12.2
./configure && make && sudo make install
sudo luarocks install luasocket
cd ..
rm -rf lua*
