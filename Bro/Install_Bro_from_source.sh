#!/bin/bash

echo "在Ubuntu 16.04部署Bro"

# 安装依赖软件包
sudo apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

# 其他依赖软件包（可选）
# https://www.bro.org/sphinx/install/install.html#id6

# 下载稳定版源码
wget https://www.bro.org/downloads/bro-2.5.5.tar.gz 
wget https://www.bro.org/downloads/bro-2.5.5.tar.gz.asc 
gpg --recv-keys 0x33f15eaef8cb8019
gpg -v bro-2.5.5.tar.gz.asc

# 安装Bro
tar -xvf bro-2.5.5.tar.gz 
cd bro-2.5.5/ 
./configure # --enable-debug 
make 
sudo make install
# export PATH=/usr/local/bro/bin:$PATH
echo "PATH=/usr/local/bro/bin:$PATH" >> ~/.profile

echo "安装目录：/usr/local/bro"
echo "执行以下命令配置环境变量：export PATH=/usr/local/bro/bin:$PATH"

# 注意：也可以安装Bro开发版：https://www.bro.org/sphinx/install/install.html#id9
