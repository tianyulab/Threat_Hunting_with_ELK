#!/bin/bash
set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately
# 如果sha256sum检查失败，脚本退出

# 运行:sh -x $0 "本机IP"

# 记录脚本行为（排错目的）
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

# Ubuntu 16.04

# 安装依赖软件包
sudo apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

# 1.安装Bro Controller
mkdir /src && mkdir -p /opt/bro && cd /opt/bro
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_osquery/Bro_Controller.tar.gz
wget https://github.com/tianyulab/Threat_Hunting_with_ELK/raw/master/Bro_osquery/Bro_Controller.tar.gz.sha256sum
sha256sum -c Bro_Controller.tar.gz.sha256sum
tar xf Bro_Controller.tar.gz

# 2.配置Bro Controller
INAME=$(ip -o link show | sed -rn '/^[0-9]+: en/{s/.: ([^:]*):.*/\1/p}')
sed -i "s/ens160/$INAME/g" /opt/bro/etc/node.cfg

export my_ip="$1"
sed -i "s/192.168.8.115/$my_ip/g" /opt/bro/etc/node.cfg

/opt/bro/bin/broctl deploy

# 3.验证
/opt/bro/bin/broctl status
netstat -tupnl | grep 9999
