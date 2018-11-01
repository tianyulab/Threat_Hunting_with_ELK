#!/bin/bash

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

# 记录脚本行为（排错目的），sh -x Deploy_Wazuh_server.sh
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

# 软件环境：
# Ubuntu 16.04
# Wazuh 3.6.x

# 1.添加Wazuh Repositories
## 1.1）安装依赖软件包
apt-get update
apt-get -y install curl apt-transport-https lsb-release
# if [ ! -f /usr/bin/python ]; then ln -s /usr/bin/python3 /usr/bin/python; fi # 可选
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/3.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

# 2.安装wazuh-manager
apt-get update
apt-get -y install wazuh-manager
systemctl status wazuh-manager
systemctl enable wazuh-manager

# 3.安装Wazuh API
## 3.1）安装依赖软件包，NodeJS >= 4.6.1，Python >= 2.7
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get -y install nodejs
apt-get -y install wazuh-api
systemctl status wazuh-api
systemctl enable wazuh-api

# 4.安装Filebeat（分布式架构）
curl -s https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-6.x.list
apt-get update
apt-get -y install filebeat=6.4.2
curl -so /etc/filebeat/filebeat.yml https://raw.githubusercontent.com/wazuh/wazuh/3.6/extensions/filebeat/filebeat.yml
# 修改/etc/filebeat/filebeat.yml中ELASTIC_SERVER_IP的值为Elastic Stack服务器IP
sed -i 's/ELASTIC_SERVER_IP/ELK IP/g' /etc/filebeat/filebeat.yml
systemctl daemon-reload
systemctl enable filebeat.service
systemctl start filebeat.service

# 5.验证
systemctl status wazuh-manager
systemctl status wazuh-api
systemctl status filebeat.service
