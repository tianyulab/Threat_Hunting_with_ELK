#!/bin/bash

echo "Ubuntu 18.04 安装Zeek(Bro) 2.6.x"

# 安装依赖软件包
sudo apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

# 其他依赖软件包（可选）
# https://docs.zeek.org/en/stable/install/install.html#optional-dependencies

# Clone源码
git clone --recursive https://github.com/zeek/zeek

# 编译 & 安装
mkdir /opt/zeek
./configure --prefix=/opt/zeek # --enable-debug 
make 
sudo make install
# export PATH=/opt/zeek/bin:$PATH
echo "PATH=/opt/zeek/bin:$PATH" >> ~/.profile

echo "安装目录：/opt/zeek"
echo "执行以下命令配置环境变量：export PATH=/opt/zeek/bin:$PATH"

# 测试
# zeek -C -i eth0 -U .status  -p standalone foo.zeek "Site::local_nets += { 192.168.8.0/24 }" --filter "host 8.8.8.8"
