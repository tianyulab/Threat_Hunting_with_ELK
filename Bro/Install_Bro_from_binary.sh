#!/bin/bash

echo "在Ubuntu 16.04部署Bro"

wget -nv http://download.opensuse.org/repositories/network:bro/xUbuntu_16.04/Release.key -O Release.key
sudo apt-key add - < Release.key
sudo apt-get update
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/network:/bro/xUbuntu_16.04/ /' > /etc/apt/sources.list.d/bro.list"
sudo apt-get update
sudo apt-get -y install bro
# export PATH=$PATH:/opt/bro/bin
echo "PATH=$PATH:/opt/bro/bin" >> ~/.profile

echo "安装目录：/opt/bro"
echo "创建名为：bro的用户和用户组"

# 注意：官方同时提供nightly binary builds：https://www.bro.org/download/nightly-packages.html

# 参考链接：
# https://www.bro.org/download/packages.html
